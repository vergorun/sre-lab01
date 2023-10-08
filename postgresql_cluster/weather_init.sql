create table if not exists public.cities
(
    id   bigserial,
    name varchar(255)
);

create table if not exists public.forecast
(
    id          bigserial,
    "cityId"    bigint,
    "dateTime"  bigint,
    temperature integer,
    summary     text
);

INSERT INTO public.cities VALUES(0,'\'Moscow\'') ON CONFLICT DO NOTHING;

INSERT INTO public.forecast VALUES(0,0,1696761713,20,'\'sample\ record,\ id\ 0\'') ON CONFLICT DO NOTHING;
