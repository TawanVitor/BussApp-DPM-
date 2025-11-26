@echo off
echo ========================================
echo Criando estrutura Clean Architecture
echo para o projeto Buss
echo ========================================
echo.

REM Criar pastas core
echo Criando pastas CORE...
mkdir lib\core\constants 2>nul
mkdir lib\core\theme 2>nul
mkdir lib\core\utils 2>nul

REM Criar pastas onboarding
echo Criando pastas ONBOARDING...
mkdir lib\features\onboarding\data\datasources 2>nul
mkdir lib\features\onboarding\data\models 2>nul
mkdir lib\features\onboarding\data\repositories 2>nul
mkdir lib\features\onboarding\domain\entities 2>nul
mkdir lib\features\onboarding\domain\repositories 2>nul
mkdir lib\features\onboarding\domain\usecases 2>nul
mkdir lib\features\onboarding\presentation\pages 2>nul
mkdir lib\features\onboarding\presentation\bloc 2>nul
mkdir lib\features\onboarding\presentation\widgets 2>nul

REM Criar pastas routes
echo Criando pastas ROUTES...
mkdir lib\features\routes\data\datasources 2>nul
mkdir lib\features\routes\data\models 2>nul
mkdir lib\features\routes\data\repositories 2>nul
mkdir lib\features\routes\domain\entities 2>nul
mkdir lib\features\routes\domain\repositories 2>nul
mkdir lib\features\routes\domain\usecases 2>nul
mkdir lib\features\routes\presentation\bloc 2>nul
mkdir lib\features\routes\presentation\pages 2>nul
mkdir lib\features\routes\presentation\widgets 2>nul

REM Criar pastas settings
echo Criando pastas SETTINGS...
mkdir lib\features\settings\data\datasources 2>nul
mkdir lib\features\settings\data\models 2>nul
mkdir lib\features\settings\data\repositories 2>nul
mkdir lib\features\settings\domain\entities 2>nul
mkdir lib\features\settings\domain\repositories 2>nul
mkdir lib\features\settings\domain\usecases 2>nul
mkdir lib\features\settings\presentation\bloc 2>nul
mkdir lib\features\settings\presentation\pages 2>nul
mkdir lib\features\settings\presentation\widgets 2>nul

echo.
echo ========================================
echo Estrutura de pastas criada com sucesso!
echo ========================================
echo.
echo Agora voce precisa mover os arquivos:
echo.
echo CORE:
echo   - Mover app_theme.dart para lib\core\theme\
echo.
echo SETTINGS:
echo   - Mover user_settings.dart para lib\features\settings\domain\entities\
echo   - Mover settings_page.dart para lib\features\settings\presentation\pages\
echo   - Mover accessibility_page.dart para lib\features\settings\presentation\pages\
echo.
echo ROUTES:
echo   - Mover bus_route.dart para lib\features\routes\domain\entities\
echo   - Mover add_route_page.dart para lib\features\routes\presentation\pages\
echo   - Mover route_list_page.dart para lib\features\routes\presentation\pages\
echo.
echo ONBOARDING:
echo   - Mover onboarding_flow.dart para lib\features\onboarding\presentation\pages\
echo   - Mover policy_viewer_screen.dart para lib\features\onboarding\presentation\pages\
echo.
echo ========================================
echo Pressione qualquer tecla para sair...
pause >nul