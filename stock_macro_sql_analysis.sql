-- verifying table loaded correctly
select count(*) from stock_macro;

-- identifying dates of large stock reaction and large inflation change
select date, sp500_return, next_return, large_reaction, inflation
from stock_macro
where abs(inflation) > (
    select avg(inflation) + 1.5 * stddev(inflation)
    from stock_macro
    )
and large_reaction != 0
order by date;

-- identifying dates of large stock reaction and large interest rate change
select date, sp500_return, next_return, large_reaction, int_rate_change
from stock_macro
where abs(int_rate_change) > (
    select avg(int_rate_change) + 1.5 * stddev(int_rate_change)
    from stock_macro
    )
and large_reaction != 0
order by date;

-- identifying dates of large stock reaction and large unemployment rate change
select date, sp500_return, next_return, large_reaction, unemp_change
from stock_macro
where abs(unemp_change) > (
    select avg(unemp_change) + 1.5 * stddev(unemp_change)
    from stock_macro
    )
and large_reaction != 0
order by date;

-- creating table showing stock reaction events and macro change events
create table macro_event_stock_reaction as
select date, sp500_return, next_return, large_reaction,
       case when abs(inflation) > (
           select avg(inflation) + 1.5 * stddev(inflation)
           from stock_macro) then 1 else 0
end as inflation_event,
    case when abs(int_rate_change) > (
        select avg(int_rate_change) + 1.5 * stddev(int_rate_change)
        from stock_macro) then 1 else 0
end interest_event,
    case when abs(unemp_change) > (
        select avg(unemp_change) + 1.5 * stddev(unemp_change)
        from stock_macro) then 1 else 0
end as unemp_event
from stock_macro;

select * from macro_event_stock_reaction;

-- do inflation events lead to reversals?
select inflation_event, avg(sp500_return) as avg, avg(next_return) as avg_next,
       avg(next_return - sp500_return) as avg_reversal
from macro_event_stock_reaction
group by inflation_event;

-- do interest events lead to reversals?
select interest_event, avg(sp500_return) as avg, avg(next_return) as avg_next,
       avg(next_return - sp500_return) as avg_reversal
from macro_event_stock_reaction
group by interest_event;

-- do unemployment events lead to reversals?
select unemp_event, avg(sp500_return) as avg, avg(next_return) as avg_next,
       avg(next_return - sp500_return) as avg_reversal
from macro_event_stock_reaction
group by unemp_event;