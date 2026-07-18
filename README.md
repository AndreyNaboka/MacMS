# MacMS

<img width="622" height="582" alt="image" src="https://github.com/user-attachments/assets/34799bca-4d0c-424b-a4c1-4c03271681a9" />


A native CPU and memory monitor for the macOS menu bar.

### Features

- two real-time menu bar graphs showing total CPU and RAM usage;
- approximately 34 seconds of usage history;
- a resizable window listing processes and their CPU and resident memory usage;
- used memory displayed both as a percentage and an absolute value;
- sorting by any column by clicking its header;
- automatic Russian interface when Russian is the primary macOS language, with English used for all other languages;
- a one-time first-launch prompt offering to open MacMS automatically at login;
- no application icon in the Dock.

### Running

macOS 13 or later and the Xcode/Swift toolchain are required.

```bash
swift run
```

Alternatively, open `Package.swift` in Xcode, select the **MacMS** scheme, and click Run.

After launching the application, click the graphs in the menu bar to open the process list.
The first CPU reading for each process is zero because two consecutive samples are required to calculate its usage.

### Building a DMG

Build a release app bundle and DMG by passing its version to the packaging script:

```bash
./scripts/build-dmg.sh 1.0.0
```

The resulting image is saved to `dist/MacMS-1.0.0-macOS-<architecture>.dmg`. The script generates the required macOS icon sizes from `Assets/AppIcon.png`, applies an ad-hoc signature, verifies the app and disk image, prints its SHA-256 checksum, and shows the command for publishing it with GitHub CLI. Ad-hoc signing does not replace Apple Developer ID signing or notarization, so macOS may warn users on first launch.

---

Нативный монитор CPU и оперативной памяти для строки меню macOS.

### Возможности

- два графика в реальном времени в строке меню, показывающие общую загрузку CPU и RAM;
- история загрузки примерно за последние 34 секунды;
- изменяемое по размеру окно со списком процессов, их загрузкой CPU и использованием резидентной памяти;
- отображение занятой оперативной памяти в процентах и в абсолютном размере;
- сортировка по любой колонке кликом по её заголовку;
- автоматический русский интерфейс, когда русский является основным языком macOS, и английский интерфейс для всех остальных языков;
- однократное предложение при первом запуске автоматически открывать MacMS при входе в систему;
- отсутствие иконки приложения в Dock.

### Запуск

Требуются macOS 13 или новее и Xcode/Swift toolchain.

```bash
swift run
```

Также можно открыть `Package.swift` в Xcode, выбрать схему **MacMS** и нажать Run.

После запуска приложения нажмите на графики в строке меню, чтобы открыть список процессов.
Первое измерение CPU для каждого процесса равно нулю, поскольку для вычисления загрузки нужны две последовательные выборки.

### Сборка DMG

Чтобы собрать приложение в режиме Release и создать DMG, передайте номер версии скрипту упаковки:

```bash
./scripts/build-dmg.sh 1.0.0
```

Готовый образ сохраняется в `dist/MacMS-1.0.0-macOS-<архитектура>.dmg`. Скрипт создаёт необходимые размеры иконки macOS из `Assets/AppIcon.png`, применяет ad-hoc подпись, проверяет приложение и образ диска, выводит контрольную сумму SHA-256 и показывает команду публикации через GitHub CLI. Ad-hoc подпись не заменяет подпись Apple Developer ID и нотарификацию, поэтому при первом запуске macOS может показать предупреждение.
