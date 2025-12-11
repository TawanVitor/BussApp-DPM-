# Carregamento de Imagem de Perfil - Settings

## 📋 Resumo

A feature de settings agora permite que o usuário:
1. Selecione uma foto da galeria
2. A foto é salva no caminho do dispositivo
3. O caminho é armazenado em SharedPreferences
4. A imagem é exibida com tratamento de erros

## 🎯 Como Funciona

### Fluxo de Carregamento:

```
Usuário clica em Câmera
    ↓
_pickImage() é chamada
    ↓
ImagePicker abre galeria
    ↓
Usuário seleciona imagem
    ↓
Arquivo é validado (existsSync)
    ↓
UserSettingsModel.save() salva em SharedPreferences
    ↓
widget.onSettingsChanged() notifica mudança
    ↓
setState() atualiza UI
    ↓
_ProfileImage widget mostra a imagem
```

### Componentes:

#### 1. **_ProfileImage Widget** (Inline)
- Verifica se o arquivo existe
- Exibe a imagem se válida
- Mostra ícone de erro se arquivo não existe
- Mostra ícone padrão se caminho é null

#### 2. **ProfileImageAvatar Widget** (Reutilizável)
- Widget separado para reutilizar em outras telas
- Suporta callback `onTap`
- Customizável (radius, backgroundColor)

#### 3. **UserSettingsModel**
- Salva em SharedPreferences com `toJson()`
- Carrega de SharedPreferences com `fromJson()`
- Persiste o caminho da imagem

## 🔧 Melhorias Implementadas

### ✅ Validação de Arquivo
```dart
final file = File(photoPath!);
if (!file.existsSync()) {
  // Mostra erro se arquivo não existe
}
```

### ✅ Tratamento de Erros
```dart
onBackgroundImageError: (exception, stackTrace) {
  debugPrint('Erro ao carregar imagem: $exception');
}
```

### ✅ Compressão de Imagem
```dart
final image = await _imagePicker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 85, // Reduz tamanho
);
```

### ✅ Feedback ao Usuário
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Foto de perfil atualizada com sucesso!'),
  ),
);
```

## 📱 Como Usar

### Na SettingsPage:

```dart
// A imagem é exibida automaticamente
_ProfileImage(
  photoPath: widget.settings.photoPath,
  radius: 50,
)

// Clique no ícone de câmera para mudar
IconButton(
  icon: const Icon(Icons.camera_alt),
  onPressed: _pickImage,
)
```

### Em Outras Telas (Usando ProfileImageAvatar):

```dart
import 'package:bussv1/features/settings/presentation/widgets/profile_image_avatar.dart';

// Exibir simples
ProfileImageAvatar(
  imagePath: userSettings.photoPath,
  radius: 40,
)

// Com callback
ProfileImageAvatar(
  imagePath: userSettings.photoPath,
  radius: 50,
  onTap: () => showProfileDialog(context),
)
```

## 🐛 Troubleshooting

### Imagem não aparece

1. **Verificar permissões no AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

2. **Verificar se arquivo ainda existe:**
```dart
final file = File(photoPath);
print('Arquivo existe: ${file.existsSync()}');
```

3. **Limpar cache da imagem:**
```dart
imageCache.clear();
imageCache.clearLiveImages();
```

### Erro "arquivo não encontrado"

- A imagem pode ter sido excluída do dispositivo
- O caminho pode ter mudado se o app foi reinstalado
- Solução: Copiar a imagem para o diretório da app

```dart
import 'package:path_provider/path_provider.dart';

Future<String> _saveImageToAppDirectory(String imagePath) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  final File savedImage = 
    await File(imagePath).copy('${appDir.path}/$fileName.jpg');
  return savedImage.path;
}
```

## 📦 Dependências Usadas

- `image_picker: ^1.0.4` - Seleção de imagens
- `shared_preferences: ^2.2.2` - Persistência de dados
- `path_provider: ^2.x.x` (opcional para salvar em app dir)

## ✨ Próximos Passos

1. **Adicionar cropping de imagem** (para melhor UX)
2. **Salvar em app directory** (mais seguro que caminho original)
3. **Implementar upload para Supabase** (sync com remoto)
4. **Adicionar compressão automática** (economizar espaço)
