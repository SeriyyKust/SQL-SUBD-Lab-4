/*drop old tables*/
drop table if exists table2 CASCADE;
drop table if exists table1 CASCADE;
/*create new tables*/
create table table1(
	department_name text not null,
	department_number int not null,
	fio_boss text not null,
	number_of_stavok int not null,
	payroll int not null,
	number_of_employed_stavok int not null,
	constraint pk_table1 primary key (department_name, department_number),
	constraint ak1_table1 unique (department_number, fio_boss)
);

create table table2(
	fio_employee text not null,
	department_name text not null,
	department_number int not null,
	share_occupied_stavki float not null,
	job_title text not null,
	characteristic text not null,
	/*constraint pk_table2 primary key (fio_employee),*/
	constraint fk1_table2 foreign key (department_name, department_number) references table1 (department_name, department_number)
);

/* INSERT Some data */
INSERT INTO table1 (department_name, department_number, fio_boss, number_of_stavok, payroll, number_of_employed_stavok)
VALUES ('grobovichkov', 1, 'rodrigez', 50, 1000, 5);
INSERT INTO table1 (department_name, department_number, fio_boss, number_of_stavok, payroll, number_of_employed_stavok)
VALUES ('ost', 2, 'petrovich', 16, 1705, 7);
INSERT INTO table1 (department_name, department_number, fio_boss, number_of_stavok, payroll, number_of_employed_stavok)
VALUES ('ohana', 3, 'stich', 9, 98, 43);

INSERT INTO table1 (department_name, department_number, fio_boss, number_of_stavok, payroll, number_of_employed_stavok)
VALUES ('four', 4, 'lans', 50, 1000, 5);
INSERT INTO table1 (department_name, department_number, fio_boss, number_of_stavok, payroll, number_of_employed_stavok)
VALUES ('five', 5, 'vans', 16, 1705, 7);
INSERT INTO table1 (department_name, department_number, fio_boss, number_of_stavok, payroll, number_of_employed_stavok)
VALUES ('six', 6, 'york', 9, 98, 43);
/* Insert boss's data */
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('petrovich', 'ost', 2, 1, 'boss', 'good');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('rodrigez', 'grobovichkov', 1, 1, 'boss', 'bad');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('stich', 'ohana', 3, 1, 'boss', 'greate');

INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('lans', 'four', 4, 1, 'boss', 'good');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('vans', 'five', 5, 1, 'boss', 'bad');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('york', 'six', 6, 1, 'boss', 'greate');
/* Insert employee's data */
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('sveta', 'grobovichkov', 1, 1, 'employee', 'good');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('sergey', 'ost', 2, 1.7, 'employee', 'bad');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('lilo', 'ohana', 3, 0.5, 'employee', 'greate');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('petrovich', 'ohana', 3, 0.3, 'employee', 'good');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('rodrigez', 'ohana', 3, 0.3, 'employee', 'bad');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('stich', 'ost', 2, 0.4, 'employee', 'greate');
INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
VALUES ('stich', 'grobovichkov', 1, 0.4, 'employee', 'greate');


drop function if exists BigStavki;
drop function if exists DepartmentNumber;
drop function if exists AllDepartmentAndNotBoss;
/*1*/
create function BigStavki() 
	returns table(fio_employee text, job_title text) as
	'
	select fio_employee, job_title from table2 t1
	where (select sum(share_occupied_stavki) from table2 t2
	where t1.fio_employee = t2.fio_employee) > 1
	group by fio_employee, job_title;
	' language sql;

EXPLAIN (ANALYZE, TIMING, FORMAT JSON) select fio_employee, job_title from table2 t1
	where (select sum(share_occupied_stavki) from table2 t2
	where t1.fio_employee = t2.fio_employee) > 1
	group by fio_employee, job_title;

create index fio_employee_index on table2(fio_employee);
create index fio_boss_index on table1(fio_boss);
create index department_number_index_t1 on table1(department_number);
create index department_number_index_t2 on table2(department_number);
create index number_of_employed_stavok_index on table1(number_of_employed_stavok);
drop index if exists number_of_employed_stavok_index;
drop index if exists fio_employee_index;
drop index if exists fio_boss_index;
drop index if exists department_number_index_t1;
drop index if exists department_number_index_t2;

/*2*/
create function DepartmentNumber(int, int) 
	returns table(department_number int) as
	'select department_number
	from table1
	where (number_of_employed_stavok < $1 or number_of_employed_stavok > $2);'
	language sql;

EXPLAIN (ANALYZE, TIMING, FORMAT JSON) select department_number
	from table1
	where (number_of_employed_stavok < 30 
		or number_of_employed_stavok > 50);


/*3*/
create function AllDepartmentAndNotBoss() 
	returns table(name text) as
	'select fio_employee from table2
	where fio_employee not in (select fio_boss from table1)
	union
	select fio_employee from table2 t2
	group by fio_employee
	having not exists(select department_number from table1
				  where department_number not in
				 (select department_number from table2
				 where t2.fio_employee = fio_employee));'
	language sql;


EXPLAIN (ANALYZE, TIMING, FORMAT JSON) select fio_employee from table2
	where fio_employee not in (select fio_boss from table1)
	union
	select fio_employee from table2 t2
	group by fio_employee
	having not exists(select department_number from table1
				  where department_number not in
				 (select department_number from table2
				 where t2.fio_employee = fio_employee));




create or replace function random_data(int) returns text as
$$
declare
	companys_name text[] := '{grobovichkov,ost,ohana,four, five, six}';
	companys_number int[] := '{1,2,3,4,5,6}';
	rand_share float[] := '{0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9}';
	minValue int = 1;
	maxValue int = 6;
	minValue_r int = 1;
	maxValue_r int = 9; 
	r int = 0;
	t int = 0;
begin
	for i in 1..$1 loop
		r := random()*(maxValue - minValue)+minValue;
		t := random()*(maxValue_r - minValue_r)+minValue_r;
		INSERT INTO table2 (fio_employee, department_name, department_number, share_occupied_stavki, job_title, characteristic)
		VALUES (random_string(10), companys_name[r],companys_number[r], rand_share[t], random_string(10), random_string(10));
	end loop;
	return '';
end;
$$ language plpgsql;

create or replace function random_data_table1(int) returns text as
$$
declare
	minValue int = 1;
	maxValue int = 100;
begin
	for i in 1..$1 loop
		INSERT INTO table1 (department_name, department_number, fio_boss, number_of_stavok, payroll, number_of_employed_stavok)
VALUES (random_string(10), i + 10, 'rodrigez',random()*(maxValue - minValue)+minValue , random()*(maxValue - minValue)+minValue,random()*(maxValue - minValue)+minValue);
	end loop;
	return '';
end;
$$ language plpgsql;


create or replace function find_time(int) 
	returns table(tm1 text, tm2 text, tm3 text) as
$$
	declare
		startTime timestamp;
		endTime interval;
	begin
		startTime := clock_timestamp();
		for i in 1..$1
		loop
			perform BigStavki();
		end loop;
		endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time BigStavki: %', endTime;
		tm1 := endTime;

		startTime := clock_timestamp();
		for i in 1..$1
		loop
			perform DepartmentNumber(30,50);
		end loop;
		endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time DepartmentNumber(30,50): %', endTime;
		tm2 := endTime;

		startTime := clock_timestamp();
		for i in 1..$1
		loop
			perform AllDepartmentAndNotBoss();
		end loop;
		endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time AllDepartmentAndNotBoss: %', endTime;
		tm3 := endTime;
		return next;
	end;
$$ language plpgsql;