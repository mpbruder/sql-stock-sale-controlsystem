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
-- SCRIPT: Criacao Database 
-- *********************************************************************************

drop database ST767_Siquele
create database ST767_Siquele
go

use ST767_Siquele
go


create table Promocao (
	codpromo numeric(12,0) PRIMARY KEY,
	dtinicio date not null,
	dtfim date not null
)
go

create table Insumo (
	codinsumo numeric(12,0) PRIMARY KEY,
	nome varchar(50) not null,
	qntestoque int not null,
	preco money,
	dtfabricacao date not null,
	dtvencimento date not null
)
go





create table Pessoa (
	codpessoa numeric(12,0) PRIMARY KEY,
	nome varchar(40) not null,
	rua varchar(50) not null,
	numero int not null,
	cep int not null,
	tipo int not null
)
go

create table Fornecedor (
	codpessoa numeric(12,0) PRIMARY KEY,
	cnpj int not null unique,
	razao_social varchar(40) not null
)
go

	alter table Fornecedor 
	add constraint FK_Fornecedor_Pessoa
	foreign key(codpessoa) references Pessoa(codpessoa)
	go

create table Pessoa_Fisica (
	codpessoa numeric(12,0) PRIMARY KEY,
	CPF int not null unique,
	dtnascimento date not null,
	telefone int,
	email varchar(50) not null
)
go

	alter table Pessoa_Fisica 
	add constraint FK_Pessoa_Fisica_Pessoa
	foreign key(codpessoa) references Pessoa(codpessoa)
	go

create table Colaborador (
	codpessoa numeric(12,0) PRIMARY KEY,
	login varchar(30) not null,
	senha varchar(50) not null,
	salario money not null,
	comissao int not null,
	numero_vendas int not null
)
go

	alter table Colaborador 
	add constraint FK_Colaborador_Pessoa_Fisica
	foreign key(codpessoa) references Pessoa_Fisica(codpessoa)
	go

create table Cliente (
	codpessoa numeric(12,0) PRIMARY KEY,
	numero_compras int not null,
	cliente_fidelidade char(1) not null,
	cliente_premium char(1) not null
)
go

	alter table Cliente 
	add constraint FK_Cliente_Pessoa_Fisica
	foreign key (codpessoa) references Pessoa_Fisica(codpessoa)
	go





create table Produto (
	codproduto numeric(12,0) PRIMARY KEY,
	nome varchar(50) not null,
	preco money not null,
	qntestoque int not null,
	dtfabricacao date not null,
	dtvencimento date not null,
	tipo int not null
)
go

create table Produto_Fabricado (
	codproduto numeric(12,0) PRIMARY KEY
)
go

	alter table Produto_Fabricado
	add constraint FK_Produto_Fabricado_Produto
	foreign key (codproduto) references Produto(codproduto)
	go

create table Produto_Industrial (
	codproduto numeric(12,0) PRIMARY KEY
)
go

	alter table Produto_Industrial
	add constraint FK_Produto_Industrial_Produto
	foreign key (codproduto) references Produto(codproduto)
	go





create table NF_VENDA (
	numnota numeric(12,0) PRIMARY KEY,
	valortotal money not null,
	data datetime not null,
	status char(1),
	cod_col numeric(12,0) not null,
	cod_cli numeric(12,0) not null
)
go

	alter table NF_VENDA
	add constraint FK_NF_VENDA_Colaborador
	foreign key (cod_col) references Colaborador(codpessoa)
	go

	alter table NF_VENDA
	add constraint FK_NF_VENDA_Cliente
	foreign key (cod_cli) references Cliente(codpessoa)
	go

	create index ixvenda_cli 
	on NF_VENDA(cod_cli)
	go

	create index ixvenda_col
	on NF_VENDA(cod_col)
	go

create table NF_COMPRA_INSUMO (
	numnota_insumo numeric(12,0) PRIMARY KEY,
	valortotal money not null,
	data datetime not null,
	quantidade int not null,
	status char(1),
	codpessoa numeric(12,0) not null,
	codinsumo numeric(12,0) not null
)
go

	alter table NF_COMPRA_INSUMO
	add constraint FK_NF_COMPRA_INSUMO_Fornecedor
	foreign key (codpessoa) references Fornecedor(codpessoa)
	go

	alter table NF_COMPRA_INSUMO
	add constraint FK_NF_COMPRA_INSUMO_Insumo
	foreign key (codinsumo) references Insumo(codinsumo)
	go

	create index ixcompra_insumo_pes
	on NF_COMPRA_INSUMO (codpessoa)
	go

	create index ixcompra_insumo_ins
	on NF_COMPRA_INSUMO (codinsumo)
	go

create table NF_COMPRA_PROD (
	numnota_prod numeric(12,0) PRIMARY KEY,
	valortotal money not null,
	data datetime not null,
	quantidade int not null,
	status char(1),
	codpessoa numeric(12,0) not null,
	codprod numeric(12,0) not null
)
go

	alter table NF_COMPRA_PROD
	add constraint FK_NF_COMPRA_PROD_Fornecedor
	foreign key (codpessoa) references Fornecedor(codpessoa)
	go

	alter table NF_COMPRA_PROD
	add constraint FK_NF_COMPRA_PROD_Produto_Industrial
	foreign key (codprod) references Produto_Industrial(codproduto)
	go

	create index ixcompra_prod_pessoa
	on NF_COMPRA_PROD(codpessoa)
	go

	create index ixcompra_prod_produto
	on NF_COMPRA_PROD(codprod)
	go





create table itemnotafiscal (
	numnota numeric(12,0) not null,
	codprod numeric(12,0) not null,
	quantidade int not null
)
go

	alter table itemnotafiscal
	ADD CONSTRAINT PK_itemnotafiscal PRIMARY KEY (numnota,codprod);
	go


	alter table itemnotafiscal
	add constraint FK_itemnotafiscal_NF_VENDA
	foreign key (numnota) references NF_VENDA(numnota)
	go

	alter table itemnotafiscal
	add constraint FK_itemnotafiscal_Produto
	foreign key (codprod) references Produto(codproduto)
	go

create table insumoproduto (
	codprod numeric(12,0) not null,
	codinsumo numeric(12,0) not null,
	quantidade int not null
)
go

	alter table insumoproduto
	ADD CONSTRAINT PK_insumoproduto PRIMARY KEY (codprod,codinsumo);
	go

	alter table insumoproduto
	add constraint FK_insumoproduto_Produto_Fabricado
	foreign key (codprod) references Produto_Fabricado(codproduto)
	go

	alter table insumoproduto
	add constraint FK_insumoproduto_Insumo
	foreign key (codinsumo) references Insumo(codinsumo)
	go

create table prodpromocao (
	codprod numeric(12,0) not null,
	codpromo numeric(12,0) not null,
	desconto int not null
)
go

	alter table prodpromocao
	ADD CONSTRAINT PK_prodpromocao PRIMARY KEY (codprod,codpromo);
	go

	alter table prodpromocao
	add constraint FK_prodpromocao_Produto
	foreign key (codprod) references Produto(codproduto)
	go

	alter table prodpromocao
	add constraint FK_prodpromocao_Promocao
	foreign key (codpromo) references Promocao(codpromo)
	go





create table Fatura (
	numfatura numeric(12,0) PRIMARY KEY,
	valorfatura money,
	dtvencimento date not null,
	dtpagamento date,
	tipo int not null
)
go

create table Fatura_Venda (
	numfatura numeric(12,0) PRIMARY KEY,
	numnota numeric(12,0)
)
go

	alter table Fatura_Venda
	add constraint FK_Fatura_Venda_Fatura
	foreign key (numfatura) references Fatura(numfatura)
	go

	alter table Fatura_Venda
	add constraint FK_Fatura_Venda_NF_VENDA
	foreign key (numnota) references NF_VENDA(numnota)
	go

	create index ixfatura_venda_numnota
	on Fatura_Venda(numnota)
	go

create table Fatura_Compraprod (
	numfatura numeric(12,0) PRIMARY KEY,
	numnota_prod numeric(12,0) not null
)
go

	alter table Fatura_Compraprod
	add constraint FK_Fatura_Compraprod_Fatura
	foreign key (numfatura) references Fatura(numfatura)
	go

	alter table Fatura_Compraprod
	add constraint FK_Fatura_Compraprod_NF_COMPRA_PROD
	foreign key (numnota_prod) references NF_COMPRA_PROD(numnota_prod)
	go

	create index ixfatura_compraprod_numnotaprod
	on Fatura_Compraprod(numnota_prod)
	go

create table Fatura_Comprainsumo (
	numfatura numeric(12,0) PRIMARY KEY,
	numnota_insumo numeric(12,0) not null
)
go

	alter table Fatura_Comprainsumo
	add constraint FK_Fatura_Comprainsumo_Fatura
	foreign key (numfatura) references Fatura(numfatura)
	go

	alter table Fatura_Comprainsumo
	add constraint FK_Fatura_Comprainsumo_NF_COMPRA_INSUMO
	foreign key (numnota_insumo) references NF_COMPRA_INSUMO(numnota_insumo)
	go

	create index ixfatura_comprainsumo_numnotains
	on Fatura_Comprainsumo(numnota_insumo)
	go


create table Fatura_paga (
	numfatura numeric(12,0) PRIMARY KEY,
	forma_pgto varchar(20),
	valorfatura money,
	dtvencimento date not null,
	dtpagamento date,
	tipo int not null
)
go