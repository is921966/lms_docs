# 📱 Создание Provisioning Profile для App Store

## Шаг 1: Откройте Apple Developer Portal

1. Перейдите на https://developer.apple.com/account
2. Войдите с вашим Apple ID
3. Перейдите в **Certificates, IDs & Profiles**

## Шаг 2: Перейдите в Profiles

1. В левом меню выберите **Profiles**
2. Нажмите кнопку **"+"** (Create a New Profile)

## Шаг 3: Выберите тип профиля

1. В разделе **Distribution** выберите:
   - **App Store Connect** (ранее называлось App Store)
2. Нажмите **Continue**

## Шаг 4: Выберите App ID

1. В списке **App ID** выберите:
   - **ru.tsum.lms.igor** (или ваш App ID)
2. Нажмите **Continue**

## Шаг 5: Выберите сертификат

1. В списке сертификатов выберите:
   - **Apple Distribution: Igor Shirokov (N85286S93X)** 
   - Это должен быть ваш новый сертификат
2. Нажмите **Continue**

## Шаг 6: Назовите профиль

1. **Provisioning Profile Name**: 
   - `LMS App Store Distribution`
   - Или любое понятное имя
2. Нажмите **Generate**

## Шаг 7: Скачайте профиль

1. После генерации нажмите **Download**
2. Файл будет называться что-то вроде `LMS_App_Store_Distribution.mobileprovision`

## Шаг 8: Получите UUID профиля

```bash
# В Terminal выполните:
cd ~/Downloads
security cms -D -i LMS_App_Store_Distribution.mobileprovision | grep -A1 'UUID' | grep -o '[0-9a-fA-F]\{8\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{12\}'

# Скопируйте UUID (будет что-то вроде: 12345678-1234-1234-1234-123456789012)
```

## Шаг 9: Кодируем в Base64

```bash
# Кодируем профиль в base64
base64 -i LMS_App_Store_Distribution.mobileprovision | pbcopy

echo "✅ Provisioning profile скопирован в буфер обмена!"
```

## Шаг 10: Добавьте в GitHub Secrets

1. Перейдите в Settings → Secrets → Actions вашего репозитория
2. Создайте новый secret:
   - **Name**: `BUILD_PROVISION_PROFILE_BASE64`
   - **Value**: Вставьте base64 (Cmd+V)
3. Создайте еще один secret:
   - **Name**: `PROVISION_PROFILE_UUID`
   - **Value**: UUID профиля из шага 8

## После создания

Мы обновим workflow чтобы:
1. Импортировать provisioning profile
2. Использовать его UUID при сборке

Это решит проблему "requires a provisioning profile"! 