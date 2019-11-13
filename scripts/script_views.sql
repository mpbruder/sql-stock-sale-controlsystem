/*
 * UNICAMP - Faculdade de Tecnologia
 * Limeira - SP
 *
 * Disciplina ST767 - Banco de Dados II
 * Projeto: Loja de salgados
 *
 *		Grupo Siquelé
 *
 *		Kevin Barrios
 *		Leonardo Alberto
 *		Matheus Bruder
 *		Matheus Rosisca
 *		Vinicius Ito
 *
 */

-- *********************************************************************************
-- SCRIPT: Manipulacao Database - VIEWS
-- *********************************************************************************

	create view produtos_estoque 
	as 
	SELECT nome,dtvencimento,qntestoque 
	FROM produto

	create view produtos_cliente 
	as 
	SELECT nome,preco,dtfabricacao,dtvencimento 
	FROM produto

	create view produtos_estoque_zero 
	as 
	SELECT nome 
	FROM produto 
	where qntestoque = 0

	create view nome_especiais 
	as 
	SELECT nome,numero_compras  
	FROM cliente  
	inner join pessoa 
		on cliente.codpessoa=pessoa.codpessoa 
	WHERE cliente_fidelidade like 's' or  cliente_premium like 's'

	create view produtos_vendidos 
	as 
	SELECT codprod,nome,preco 
	FROM produto 
	inner join itemnotafiscal 
		on produto.codproduto=itemnotafiscal.codprod

	create view produtos_mais_frequentes 
	as 
	SELECT codprod,nome,COUNT(codproduto)as numero_vendas 
	FROM produto 
	inner join itemnotafiscal 
		on produto.codproduto=itemnotafiscal.codprod 
	GROUP by codproduto order by numero_vendas desc

	create view itens_mais_vendidos 
	as 
	SELECT codprod,nome,SUM(quantidade)as quantidade_vendida,COUNT(codproduto)as numero_vendas 
	FROM produto 
	inner join itemnotafiscal 
		on produto.codproduto=itemnotafiscal.codprod 
	GROUP by codproduto order by quantidade_vendida desc
