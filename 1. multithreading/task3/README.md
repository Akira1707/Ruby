# Task 03 (Julia) – Анализ данных датчиков

## Описание
Программа читает несколько CSV-файлов с данными о температуре и влажности,
обрабатывает их параллельно и вычисляет средние значения для каждого файла и общий отчёт.

## Входные данные
Каталог `sensor_data/` с CSV-файлами вида:
timestamp,temperature,humidity
2025-11-12 10:00,22.5,55

## Выходные данные
Файл `sensor_report.json`:
{
    "per_file": [
        {"file": "sensor1.csv", "average_temperature": 22.77, "average_humidity": 55.0},
        {"file": "sensor2.csv", "average_temperature": 21.43, "average_humidity": 60.0}
    ],
    "overall": {
        "overall_average_temperature": 22.1,
        "overall_average_humidity": 57.5
    }
}

## Запуск
using Pkg
Pkg.add(["CSV", "DataFrames", "JSON", "Distributed"])

julia task3.jl
