# MacMS

## English

A native CPU and memory monitor for the macOS menu bar.

### Features

- two real-time menu bar graphs showing total CPU and RAM usage;
- approximately 34 seconds of usage history;
- a resizable window listing processes and their CPU and resident memory usage;
- used memory displayed both as a percentage and an absolute value;
- sorting by any column by clicking its header;
- no application icon in the Dock.

### Running

macOS 13 or later and the Xcode/Swift toolchain are required.

```bash
swift run
```

Alternatively, open `Package.swift` in Xcode, select the **MacMS** scheme, and click Run.

After launching the application, click the graphs in the menu bar to open the process list.
The first CPU reading for each process is zero because two consecutive samples are required to calculate its usage.

---

## Русский

Нативный монитор CPU и оперативной памяти для строки меню macOS.

### Возможности

- два графика в реальном времени в строке меню, показывающие общую загрузку CPU и RAM;
- история загрузки примерно за последние 34 секунды;
- изменяемое по размеру окно со списком процессов, их загрузкой CPU и использованием резидентной памяти;
- отображение занятой оперативной памяти в процентах и в абсолютном размере;
- сортировка по любой колонке кликом по её заголовку;
- отсутствие иконки приложения в Dock.

### Запуск

Требуются macOS 13 или новее и Xcode/Swift toolchain.

```bash
swift run
```

Также можно открыть `Package.swift` в Xcode, выбрать схему **MacMS** и нажать Run.

После запуска приложения нажмите на графики в строке меню, чтобы открыть список процессов.
Первое измерение CPU для каждого процесса равно нулю, поскольку для вычисления загрузки нужны две последовательные выборки.
