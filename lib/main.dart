import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MinhaAplicacao());
}

class MinhaAplicacao extends StatelessWidget {
  const MinhaAplicacao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consulta de CEP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const CepPage(),
    );
  }
}

class CepPage extends StatefulWidget {
  const CepPage({super.key});

  @override
  State<CepPage> createState() => _CepPageState();
}

class _CepPageState extends State<CepPage> {
  final TextEditingController cepController =
  TextEditingController();

  String resultado = '';

  bool carregando = false;

  double? latitude;
  double? longitude;

  // =========================================================
  // CONSULTA DO CEP
  // =========================================================

  Future<void> consultarCep() async {
    final String cep = cepController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    // =======================================================
    // VALIDAÇÃO
    // =======================================================

    if (cep.length != 8) {
      setState(() {
        resultado =
        'Digite um CEP válido com 8 números.';
        latitude = null;
        longitude = null;
      });

      return;
    }

    setState(() {
      carregando = true;
      resultado = 'Consultando...';
      latitude = null;
      longitude = null;
    });

    try {
      // =====================================================
      // 1. VIACEP
      // =====================================================

      final urlViaCep = Uri.parse(
        'https://viacep.com.br/ws/$cep/json/',
      );

      final respostaViaCep =
      await http.get(urlViaCep);

      if (respostaViaCep.statusCode != 200) {
        setState(() {
          resultado =
          'Erro ao consultar o ViaCEP.';
        });

        return;
      }

      final dadosViaCep =
      jsonDecode(respostaViaCep.body);

      // CEP inexistente
      if (dadosViaCep['erro'] == true) {
        setState(() {
          resultado = 'CEP não encontrado.';
        });

        return;
      }

      // =====================================================
      // DADOS DO ENDEREÇO
      // =====================================================

      final String logradouro =
          dadosViaCep['logradouro'] ?? '';

      final String bairro =
          dadosViaCep['bairro'] ?? '';

      final String cidade =
          dadosViaCep['localidade'] ?? '';

      final String uf =
          dadosViaCep['uf'] ?? '';

      final String cepRetornado =
          dadosViaCep['cep'] ?? cep;

      // =====================================================
      // 2. NOMINATIM
      // =====================================================
      //
      // Aqui substituímos a BrasilAPI somente para TESTE.
      //
      // A consulta usa:
      //
      // rua
      // cidade
      // estado
      // CEP
      // país
      //
      // =====================================================

      final parametros = {
        'street': logradouro,
        'city': cidade,
        'state': uf,
        'postalcode': cep,
        'country': 'Brazil',
        'countrycodes': 'br',
        'format': 'jsonv2',
        'limit': '1',
      };

      final urlNominatim = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        parametros,
      );

      final respostaNominatim =
      await http.get(
        urlNominatim,
        headers: {
          'User-Agent':
          'tarefa_05_flutter/1.0 (projeto educacional)',
          'Accept-Language': 'pt-BR',
        },
      );

      // =====================================================
      // VERIFICA NOMINATIM
      // =====================================================

      if (respostaNominatim.statusCode != 200) {
        setState(() {
          resultado =
          'O endereço foi encontrado, mas o serviço '
              'de localização não respondeu.';
        });

        return;
      }

      final resultados =
      jsonDecode(respostaNominatim.body);

      if (resultados is! List ||
          resultados.isEmpty) {
        setState(() {
          resultado =
          'Endereço encontrado, mas não foi possível '
              'localizar esse endereço no mapa.';
        });

        return;
      }

      // =====================================================
      // 3. LATITUDE E LONGITUDE
      // =====================================================

      final double? novaLatitude =
      double.tryParse(
        resultados[0]['lat'].toString(),
      );

      final double? novaLongitude =
      double.tryParse(
        resultados[0]['lon'].toString(),
      );

      if (novaLatitude == null ||
          novaLongitude == null) {
        setState(() {
          resultado =
          'A API não retornou coordenadas válidas.';
        });

        return;
      }

      latitude = novaLatitude;
      longitude = novaLongitude;

      // =====================================================
      // 4. MOSTRA OS DADOS
      // =====================================================

      setState(() {
        resultado =
        'Logradouro: $logradouro\n'
            'Bairro: $bairro\n'
            'Cidade: $cidade\n'
            'UF: $uf\n'
            'CEP: $cepRetornado\n\n'
            'Latitude: '
            '${latitude!.toStringAsFixed(6)}\n'
            'Longitude: '
            '${longitude!.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        resultado =
        'Não foi possível realizar a consulta.\n\n'
            'Verifique sua conexão com a internet.';

        latitude = null;
        longitude = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    cepController.dispose();
    super.dispose();
  }

  // =========================================================
  // INTERFACE
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consulta de CEP',
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [
            // =================================================
            // CAMPO CEP
            // =================================================

            TextField(
              controller: cepController,
              keyboardType:
              TextInputType.number,
              maxLength: 8,

              decoration: const InputDecoration(
                labelText: 'Digite o CEP',
                hintText: 'Ex.: 58038241',
                prefixIcon:
                Icon(Icons.location_on),
                border:
                OutlineInputBorder(),
                counterText: '',
              ),
            ),

            const SizedBox(height: 12),

            // =================================================
            // BOTÃO
            // =================================================

            ElevatedButton.icon(
              onPressed:
              carregando
                  ? null
                  : consultarCep,

              icon: carregando
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.search,
              ),

              label: Text(
                carregando
                    ? 'Consultando...'
                    : 'Consultar CEP',
              ),

              style:
              ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // RESULTADO
            // =================================================

            if (resultado.isNotEmpty)
              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),

                  child: Text(
                    resultado,

                    style:
                    const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // =================================================
            // MAPA
            // =================================================

            if (latitude != null &&
                longitude != null)
              SizedBox(
                height: 400,

                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12),

                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter:
                      LatLng(
                        latitude!,
                        longitude!,
                      ),

                      initialZoom: 16,

                      minZoom: 3,

                      maxZoom: 19,
                    ),

                    children: [
                      // =======================================
                      // OPENSTREETMAP
                      // =======================================

                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/'
                            '{z}/{x}/{y}.png',

                        userAgentPackageName:
                        'com.example.tarefa_05',

                        maxZoom: 19,
                      ),

                      // =======================================
                      // MARCADOR
                      // =======================================

                      MarkerLayer(
                        markers: [
                          Marker(
                            point:
                            LatLng(
                              latitude!,
                              longitude!,
                            ),

                            width: 80,

                            height: 80,

                            alignment:
                            Alignment.center,

                            child:
                            const Icon(
                              Icons.location_on,

                              color:
                              Colors.red,

                              size: 60,
                            ),
                          ),
                        ],
                      ),

                      // =======================================
                      // ATRIBUIÇÃO
                      // =======================================

                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}