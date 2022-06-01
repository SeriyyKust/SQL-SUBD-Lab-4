drop index if exists index_t2_f1;
drop index if exists index_t3_f1;
drop index if exists index_t4_f1;
drop index if exists index_t5_f1;

drop table if exists t1;
drop table if exists t2;
drop table if exists t3;
drop table if exists t4;
drop table if exists t5;


create table t1(
	f1 int,
	f2 varchar(80)
);

create table t2(
	f1 int,
	f2 varchar(80)
);

create table t3(
	f1 int,
	f2 varchar(80)
);

create table t4(
	f1 int,
	f2 varchar(80)
);

create table t5(
	f1 int,
	f2 varchar(80)
);



/*Indexes*/

create or replace function myf5(x integer)
	returns integer 
as $$
begin
	if mod($1,1) = 0
	then return 1+$1;
	else return 1-$1;
	end if;
end;
$$ language plpgsql immutable;

create index index_t2_f1 on t2(f1);

create unique index index_t3_f1 on t3(f1);

create index index_t4_f1 on t4((abs(f1) + 1));

create index index_t5_f1 on t5(myf5(f1));




drop procedure if exists fill_table;
create or replace procedure fill_table(c int)
	language plpgsql
as $$
	declare 
		NeededRows integer := c;
		minValue int = 0;
		maxValue int = 256;
		rand_f1 int;
		rand_f2 varchar(80);
	begin
		for i in 1..NeededRows
		loop
			rand_f1 := random()*(maxValue - minValue)+minValue;
			rand_f2 := random_string(80);
			insert into t1 (f1,f2) 
			values(rand_f1,rand_f2);
			insert into t2 (f1,f2)
			values(rand_f1,rand_f2);
			if mod(i,256) = 0 then commit; end if;
		end loop;
		commit;
	end;
$$;


Create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;


--SELECT
create or replace function select_function(int) 
	returns table(tm1 text, tm2 text) as
$$
	declare
		startTime1 timestamp;
		endTime1 interval;
		startTime2 timestamp;
		endTime2 interval;
		rand_num int[1000000];
		minValue int = 0;
		maxValue int = 256;
	begin
		for i in 1..$1
		loop
			rand_num[i] := random()*(maxValue - minValue)+minValue;
		end loop;
		startTime1 := clock_timestamp();
		for i in 1..$1
		loop
			perform f1 from t1 where f1 = rand_num[i];
		end loop;
		endTime1 := clock_timestamp() - startTime1;
		tm1 := endTime1;
		RAISE NOTICE 'Time on t1: %', endTime1;
		startTime2 := clock_timestamp();
		for i in 1..$1
		loop
			perform f1 from t2 where f1 = rand_num[i];
		end loop;
		endTime2 := clock_timestamp() - startTime2;
		RAISE NOTICE 'Time on t2: %', endTime2;
		tm2 := endTime2;
		return next;
	end;
$$ language plpgsql;


--INSERT
create or replace function insert_function(int)
	returns table(tm1 text, tm2 text, tm3 text, tm4 text, tm5 text)
as $$
declare
	startTime timestamp;
	endTime interval;
	minValue int = 0;
	maxValue int = 131072;
	rand_num int[1000000];
	rand_text text[1000000];
begin
	for i in 1..$1
		loop
			rand_num[i] := random()*(maxValue - minValue)+minValue;
			rand_text[i] := random_string(80);
		end loop;
	startTime := clock_timestamp();
	for i in 1..$1
	loop
		insert into t1(f1,f2) values(rand_num[i],rand_text[i]);
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t1: %', endTime;
	tm1 := endTime;

	startTime := clock_timestamp();
	for i in 1..$1
	loop
		insert into t2(f1,f2) values(rand_num[i],rand_text[i]);
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t2: %', endTime;
	tm2 := endTime;

	startTime := clock_timestamp();
	for i in 1..$1
	loop
		insert into t4(f1,f2) values(rand_num[i],rand_text[i]);
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t4: %', endTime;
	tm4 := endTime;

	startTime := clock_timestamp();
	for i in 1..$1
	loop
		insert into t5(f1,f2) values(rand_num[i],rand_text[i]);
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t5: %', endTime;
	tm5 := endTime;
	return next;
end;
$$ language plpgsql;


--INSERT TABLE 3
create or replace function insert_function_t3(int,int)
	returns table(tm1 text)
as $$
declare
	startTime timestamp;
	endTime interval;
	minValue int = 0;
	maxValue int = 131072;
	rand_text text[1000000];
begin
	for i in 1..$2
		loop
			rand_text[i] := random_string(80);
		end loop;
	startTime := clock_timestamp();
	for i in $1..$2
	loop
		insert into t3(f1,f2) values(i,rand_text[i]);
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t3: %', endTime;
	tm1 := endTime;
	return next;
end;
$$ language plpgsql;



--UPDATE
create or replace function update_function(int,int)
	returns table(tm1 text, tm2 text, tm3 text, tm4 text, tm5 text)
as $$
declare
	startTime timestamp;
	endTime interval;
	minValue int = 0;
	maxValue int = 131072;
	rand_num int[1000000];
	rand_text text[1000000];
begin
	for i in 1..$1
		loop
			rand_num[i] := random()*(maxValue - minValue)+minValue;
		end loop;
	startTime := clock_timestamp();
	for i in 1..$1
	loop
		update t1 set f1 = f1 + $2 where f1 = rand_num[i];
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t1: %', endTime;
	tm1 := endTime;

	startTime := clock_timestamp();
	for i in 1..$1
	loop
		update t2 set f1 = f1 + $2 where f1 = rand_num[i];
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t2: %', endTime;
	tm2 := endTime;

	startTime := clock_timestamp();
	for i in 1..$1
	loop
		update t3 set f1 = f1 + $2 where f1 = rand_num[i];
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t3: %', endTime;
	tm3 := endTime;

	startTime := clock_timestamp();
	for i in 1..$1
	loop
		update t4 set f1 = f1 + $2 where f1 = rand_num[i];
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t4: %', endTime;
	tm4 := endTime;

	startTime := clock_timestamp();
	for i in 1..$1
	loop
		update t5 set f1 = f1 + $2 where f1 = rand_num[i];
	end loop;
	endTime := clock_timestamp() - startTime;
		RAISE NOTICE 'Time on t5: %', endTime;
	tm5 := endTime;
	return next;
end;
$$ language plpgsql;

