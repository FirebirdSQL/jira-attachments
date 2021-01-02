
/** Test Case 1, Returns 18 Rows **/
with recursive c (id,name,avgage)
as

(
    select customers.id, customers.name, 0 as avgage from customers
        where customers.parentid is null
    union all
    select customers.id, customers.name, 0 as avgage from customers
        join c as parent on parent.id = customers.parentid
)

select * from c





/** Test Case 2, Returns 15 Rows **/
with recursive c (id,name,avgage)
as

(
    select customers.id, customers.name, average.age as avgage from customers
        join (select customers.id as customersid, AVG(COALESCE(contacts.age,0)) as age
                from customers
                    left join contacts on contacts.customer = customers.id
                group by 1) as average on average.customersid = customers.id
        where customers.parentid is null
    union all
    select customers.id, customers.name, average.age as avgage from customers
        join c as parent on parent.id = customers.parentid
        join (select customers.id as customersid, AVG(COALESCE(contacts.age,0)) as age
                from customers
                    left join contacts on contacts.customer = customers.id
                group by 1) as average on average.customersid = customers.id
)

select * from c