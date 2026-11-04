# Desafio de Arquitetura: Engenharia Reversa e Views no E-commerce

**Aluno:** Wesley Brene Batista  
**Curso:** Engenharia de Software  
**Disciplina:** Banco de Dados  
**Professor:** Leonardo Rocha  
**Ano:** 2026

## 1. Introdução

Nesta atividade, analisei uma View do banco de dados `classicmodels` que foi criada para mostrar o valor dos pedidos enviados em 2004. O problema é que a consulta original também considera pedidos que não deveriam entrar no relatório financeiro. O objetivo é identificar o erro, corrigir a View e explicar suas vantagens.

## 2. Diagnóstico do problema

O código original usa `JOIN` para juntar as tabelas `customers`, `orders` e `orderdetails`. Essas junções estão relacionadas pelas chaves corretas. O principal erro não está no `JOIN`, mas na falta de filtros.

Sem a cláusula `WHERE`, a consulta soma valores de pedidos de qualquer ano e de qualquer situação, incluindo `Cancelled` (cancelados) e `On Hold` (em espera). Assim, o relatório pode mostrar valores que não correspondem aos pedidos enviados em 2004.

Também é importante lembrar que a expressão `SUM(quantityOrdered * priceEach)` calcula o **valor dos pedidos**, não o lucro da empresa, pois não desconta os custos.

## 3. Refatoração da View

Para corrigir, mantive as junções e acrescentei os filtros de status e data. Também agrupei pelo nome do cliente e pelo número do pedido.

```sql
USE classicmodels;

CREATE OR REPLACE VIEW view_relatorio_financeiro AS
SELECT
    c.customerName,
    o.orderNumber,
    SUM(od.quantityOrdered * od.priceEach) AS valor_total
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
WHERE o.status = 'Shipped'
  AND o.orderDate >= '2004-01-01'
  AND o.orderDate < '2005-01-01'
GROUP BY c.customerName, o.orderNumber;
```

A condição `status = 'Shipped'` seleciona apenas pedidos enviados. As condições com `orderDate` limitam os pedidos ao ano de 2004.

### 3.1 Consultas para testar

Depois de executar a criação da View no MySQL com a base `classicmodels`, é possível consultar o relatório:

```sql
SELECT * FROM view_relatorio_financeiro;
```

Para verificar se algum pedido cancelado ou de outro ano entrou no resultado, pode-se executar:

```sql
SELECT v.orderNumber, o.status, o.orderDate
FROM view_relatorio_financeiro v
JOIN orders o ON v.orderNumber = o.orderNumber
WHERE o.status <> 'Shipped'
   OR o.orderDate < '2004-01-01'
   OR o.orderDate >= '2005-01-01';
```

**Resultado esperado:** nenhuma linha. Isso precisa ser confirmado executando a consulta no banco de dados; não foi feito teste prático neste documento.

## 4. Síntese teórica: segurança e abstração

### 4.1 Segurança de dados

Uma View pode mostrar somente as colunas necessárias para uma pessoa ou setor. Por exemplo, o financeiro pode consultar nome do cliente, número do pedido e valor total sem precisar visualizar todos os dados das tabelas originais. No MySQL, o acesso depende das permissões configuradas, então criar uma View sozinha não garante a segurança. É preciso controlar os privilégios de cada usuário (MYSQL, [s. d.]).

### 4.2 Abstração da complexidade

Uma View facilita consultas que seriam longas. Em vez de escrever todos os `JOINs`, filtros e cálculos sempre que precisar do relatório, o usuário pode executar apenas `SELECT * FROM view_relatorio_financeiro;`. A lógica fica reunida em um lugar, o que ajuda na organização e diminui a chance de repetir erros. A videoaula do CFBCursos (2020) apresenta a View como uma tabela virtual baseada em uma consulta.

## 5. Conclusão

Com esta atividade, entendi que um código SQL pode funcionar e ainda assim trazer informações erradas quando faltam condições importantes. No caso analisado, o erro foi não filtrar os pedidos enviados em 2004. A View corrigida organiza o relatório e pode facilitar o acesso às informações, desde que as permissões sejam configuradas corretamente.

## Referências

CFBCURSOS. **Criando e usando View em SQL - Curso de SQL - Aula 17**. YouTube, 28 dez. 2020. Disponível em: https://www.youtube.com/watch?v=ceas5MdwuoU. Acesso em: 3 nov. 2026.

MYSQL. **MySQL 8.4 Reference Manual: CREATE VIEW Statement**. [S. l.]: Oracle, [s. d.]. Disponível em: https://dev.mysql.com/doc/refman/8.4/en/create-view.html. Acesso em: 3 nov. 2026.
