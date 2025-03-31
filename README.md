# Mara Vicentina Pinto RA:1012023100321

# Aplicativo Finance Manager

Este repositório contém o código-fonte do Aplicativo Finance Manager, uma solução móvel desenvolvida para auxiliar usuários no controle detalhado de suas receitas, despesas e investimentos, proporcionando uma gestão financeira eficaz e intuitiva.

## Pré-requisitos

Antes de começar, certifique-se de ter instalado os seguintes itens no seu computador:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Git](https://git-scm.com/downloads)
- Um editor de texto ou IDE (recomendado: [Android Studio](https://developer.android.com/studio) ou [Visual Studio Code](https://code.visualstudio.com/))

## Como executar o projeto

### 1. Clone o repositório

Abra o terminal e execute o comando abaixo:

```bash
git clone https://github.com/mara-vicentina/finance-manager-app
```

### 2. Acesse o diretório do projeto

Entre no diretório que foi clonado:

```bash
cd finance-manager-app
```

### 3. Instale as dependências

Execute o seguinte comando para instalar todas as dependências necessárias:

```bash
flutter pub get
```

### 4. Executar o aplicativo no modo debug

Conecte seu dispositivo móvel ou abra um emulador e execute o comando:

```bash
flutter run
```
## 5. Rodando os testes

Para executar os testes automatizados presentes no projeto, utilize o seguinte comando:

```bash
flutter test
```

## Gerar APK (Build)

Para gerar um APK utilizável do projeto, execute:

```bash
flutter build apk --release
```

O arquivo APK gerado estará disponível no seguinte caminho:

```
build/app/outputs/flutter-apk/app-release.apk
```

