# MacMS. A native CPU and memory monitor for the macOS menu bar.

<img width="618" height="580" alt="image" src="https://github.com/user-attachments/assets/65280cc1-626f-4f06-9869-e072b447f256" />


### Features

- two real-time menu bar graphs showing total CPU and RAM usage;
- approximately 34 seconds of usage history;
- a resizable window listing processes and their CPU and resident memory usage;
- occupied physical memory calculated from active, wired, and compressor memory;
- system memory pressure indicated by RAM graph color, with separate cached, compressed, and swap statistics;
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

### How RAM monitoring works

The RAM percentage represents occupied physical memory rather than memory pressure or simply `total − free`. MacMS calculates it from:

```text
Active memory + Wired memory + Physical compressor memory
```

- **Active memory** contains pages currently being used by applications and the system.
- **Wired memory** is required by macOS and cannot be paged out or immediately reclaimed.
- **Compressed memory** in this calculation is the physical RAM occupied by the memory compressor.
- **Cached** shows file-backed memory that macOS can reclaim when applications need more RAM.
- **Swap** shows memory currently moved to disk.

Cached and compressed values provide additional context and should not be added to the occupied percentage: macOS memory categories can overlap and have different reclaimability rules.

The RAM graph color represents the system Memory Pressure reported by macOS:

- blue — normal;
- yellow — warning;
- red — critical.

A high occupied-memory percentage is not necessarily a problem when the graph remains blue. macOS intentionally uses otherwise idle RAM for caching; Memory Pressure is the better indicator of whether the system is actually running short of memory.

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
- расчёт занятой физической памяти на основе активной, wired- и compressor-памяти;
- отображение системной нагрузки памяти цветом графика RAM и отдельных значений кэша, сжатой памяти и swap;
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

### Как работает мониторинг RAM

Процент RAM показывает занятую физическую память, а не Memory Pressure и не простую разницу `всего − свободно`. MacMS рассчитывает его по формуле:

```text
Активная память + Wired-память + Физическая память компрессора
```

- **Активная память** содержит страницы, которые сейчас используются приложениями и системой.
- **Wired-память** необходима macOS и не может быть выгружена или немедленно освобождена.
- **Сжатая память** в этом расчёте — физическая RAM, занятая системным компрессором памяти.
- **Кэш** показывает file-backed память, которую macOS может освободить, когда приложениям потребуется больше RAM.
- **Swap** показывает память, перемещённую на диск.

Значения кэша и сжатой памяти дают дополнительную информацию, но их не следует прибавлять к проценту занятой RAM: категории памяти macOS могут пересекаться и имеют разные правила освобождения.

Цвет графика RAM отображает системную Memory Pressure, которую сообщает macOS:

- синий — нормальная;
- жёлтый — повышенная;
- красный — критическая.

Высокий процент занятой памяти не обязательно означает проблему, если график остаётся синим. macOS специально использует незадействованную RAM для кэширования; Memory Pressure лучше показывает, действительно ли системе не хватает памяти.

### Сборка DMG

Чтобы собрать приложение в режиме Release и создать DMG, передайте номер версии скрипту упаковки:

```bash
./scripts/build-dmg.sh 1.0.0
```

Готовый образ сохраняется в `dist/MacMS-1.0.0-macOS-<архитектура>.dmg`. Скрипт создаёт необходимые размеры иконки macOS из `Assets/AppIcon.png`, применяет ad-hoc подпись, проверяет приложение и образ диска, выводит контрольную сумму SHA-256 и показывает команду публикации через GitHub CLI. Ad-hoc подпись не заменяет подпись Apple Developer ID и нотарификацию, поэтому при первом запуске macOS может показать предупреждение.
