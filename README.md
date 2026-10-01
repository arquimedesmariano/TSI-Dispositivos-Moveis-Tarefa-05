# Tarefa Avaliativa 05 – Consulta de CEP e Localização

Aplicativo desenvolvido em Flutter para consulta de CEP, obtenção dos dados do endereço e localização geográfica em um mapa.

## 📱 Sobre o projeto

O aplicativo permite que o usuário informe um CEP e consulte:

- Logradouro
- Bairro
- Cidade
- Estado
- CEP
- Latitude
- Longitude

Após a consulta, a localização é apresentada em um mapa com um marcador.

## 🔄 Funcionamento

O fluxo do aplicativo é:

CEP informado pelo usuário  
↓  
ViaCEP  
↓  
Dados do endereço  
↓  
Nominatim / OpenStreetMap  
↓  
Latitude e Longitude  
↓  
Flutter Map  
↓  
Mapa com marcador

## 🌐 APIs e tecnologias utilizadas

### ViaCEP

Utilizada para consultar os dados postais do CEP.

Exemplo:

`https://viacep.com.br/ws/58038241/json/`

### Nominatim / OpenStreetMap

Utilizado para obter as coordenadas geográficas do endereço.

O aplicativo utiliza os dados de:

- Logradouro
- Cidade
- Estado
- CEP
- País

para realizar a geocodificação.

### Flutter Map

Biblioteca utilizada para apresentar o mapa e posicionar o marcador.

## 📦 Dependências

Principais dependências utilizadas:

- `http`
- `flutter_map`
- `latlong2`

### http

Responsável pela comunicação com as APIs.

### flutter_map

Responsável pela exibição do mapa.

### latlong2

Utilizada para trabalhar com latitude e longitude.

## 🧪 Teste realizado

Foi utilizado o CEP:

**58038-241**

Resultado:

- **Logradouro:** Avenida Pombal
- **Bairro:** Manaíra
- **Cidade:** João Pessoa
- **UF:** PB
- **CEP:** 58038-241

A localização foi apresentada corretamente no mapa, com marcador na região de Manaíra, em João Pessoa/PB.

## 🔧 Tratamento de erros

O aplicativo realiza validações para situações como:

- CEP vazio;
- CEP com quantidade incorreta de números;
- CEP inexistente;
- Falha na comunicação com a API;
- Ausência de conexão com a internet;
- Coordenadas não encontradas.

## 📂 Estrutura do projeto

```text
tarefa_05/
├── android/
├── apk/
│   └── Tarefa-05.apk
├── lib/
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
