Часть 1
1. Эксперимент по определению производительности выборки с использованием индексов. Для оценки производительности будем производить выборку по одной записи из таблицы в цикле, без использования индексов и с использованием индексов.

2. Аналогично эксперимент по определению производительности вставки с использованием индексов. Для оценки производительности нам понадобиться пять сходных таблиц:
	1. без индекса;
	2. с простым индексом;
	3. с уникальным индексом;
	4. с индексом по выражению;
	5. с индексом с использованием пользовательской функции.
После чего произведём в каждую таблицу вставку 1000 записей с замером времени вставки (не менее шести раз в каждую, как и в предыдущем примере).

3. Аналогично проведите эксперимент по определению производительности обновления данных. Общий порядок исследования производительности обновления соответствует общему порядку исследования производительности вставки данных.


Часть 2
2. Задаём индексы для отношений и запросов, созданных в
лабораторных работах ранее, для случаев, которые, по вашей
оценке, могут дать прирост производительности. Учтите
селективность данных.



