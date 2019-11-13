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
-- SCRIPT: Manipulacao Database - PROCEDURES
-- *********************************************************************************

/* Cadastro de Fornecedor */
create procedure cadastro_fornecedor
@codpessoa numeric(12,0),
@nome varchar(40),
@rua varchar(50),
@numero int,
@cep int,
@cnpj int,
@razaosocial varchar(40)
as
begin transaction
	insert into Pessoa(codpessoa, nome, rua, numero, cep, tipo)
	values(@codpessoa, @nome, @rua, @numero, @cep, 0)
	if @@ROWCOUNT > 0
		begin
			insert into Fornecedor(codpessoa, cnpj, razao_social)
			values(@codpessoa, @cnpj, @razaosocial)
			if @@ROWCOUNT > 0
				begin	
					commit transaction
					return 1
				end
			else
				begin
					rollback transaction
					return 0
				end
		end
	else
		begin
			rollback transaction
			return 0
		end

	

/* Cadastro de Cliente */
create procedure cadastro_cliente
@codpessoa numeric(12,0),
@nome varchar(40),
@rua varchar(50),
@numero int,
@cep int,
@CPF int,
@dtnascimento date,
@telefone int,
@email varchar(50)
as
begin transaction
	if not exists (select * from Pessoa where codpessoa = @codpessoa)
	begin
		insert into Pessoa(codpessoa, nome, rua, numero, cep, tipo)
		values(@codpessoa, @nome, @rua, @numero, @cep, 1)
		if @@ROWCOUNT > 0
			begin
				insert into Pessoa_Fisica
				values(@codpessoa, @CPF, @dtnascimento, @telefone, @email)
				if @@ROWCOUNT = 0
					begin 
						rollback transaction
						return 0
					end
			end
	end
	insert into Cliente 
	values(@codpessoa, 0, 'N', 'N')
	if @@ROWCOUNT > 0
		begin 
			commit transaction
			return 1
		end
	else
		begin
			rollback transaction
			return 0
		end





/* Cadastro de Colaborador */
create procedure cadastro_colaborador
@codpessoa numeric(12,0),
@nome varchar(40),
@rua varchar(50),
@numero int,
@cep int,
@CPF int,
@dtnascimento date,
@telefone int,
@email varchar(50),
@login varchar(30),
@senha varchar(50),
@salario money
as
begin transaction
	if not exists (select * from Pessoa where codpessoa = @codpessoa)
	begin
		insert into Pessoa(codpessoa, nome, rua, numero, cep, tipo)
		values(@codpessoa, @nome, @rua, @numero, @cep, 1)
		if @@ROWCOUNT > 0
			begin
				insert into Pessoa_Fisica
				values(@codpessoa, @CPF, @dtnascimento, @telefone, @email)
				if @@ROWCOUNT = 0
					begin 
						rollback transaction
						return 0
					end
			end
	end
	insert into Colaborador 
	values(@codpessoa, @login, @senha, @salario, 0, 0)
	if @@ROWCOUNT > 0
		begin 
			commit transaction
			return 1
		end
	else
		begin
			rollback transaction
			return 0
		end




/* Cadastro de Produto Fabricado */
create procedure cadastro_prod_fabricado
@codproduto numeric(12,0),
@codinsumo numeric(12,0),
@quantidade_insumo int,
@nome varchar(50),
@preco money,
@qntestoque int,
@dtfabricacao date
as
begin transaction
	insert into Produto(codproduto, nome, preco, qntestoque, dtfabricacao, dtvencimento, tipo)
	values(@codproduto, @nome, @preco, @qntestoque, @dtfabricacao, DATEADD(day, 7, @dtfabricacao), 0)
	if @@ROWCOUNT > 0
		begin
			insert into Produto_Fabricado(codproduto)
			values(@codproduto)
			if @@ROWCOUNT > 0
			begin
				insert into insumoproduto
				values(@codproduto, @codinsumo, @quantidade_insumo)
				if @@ROWCOUNT > 0
				begin
					commit transaction
					return 1
				end
			end
		end
		else
			begin
				rollback transaction
				return 0
			end

	

/* Cadastro de Venda */
create procedure venda
@numnota numeric(12,0),
@codprod numeric(12,0),
@quantidade int,
@codcliente numeric(12,0),
@codcolaborador numeric(12,0)
as
begin transaction
	if not exists (select * from NF_VENDA where numnota = @numnota and status = 1)
	begin
		insert into NF_VENDA(numnota, valortotal, data, status, cod_col, cod_cli)
		values(@numnota, 0, GETDATE(), 1, @codcolaborador, @codcliente)
	end
	insert into itemnotafiscal(numnota, codprod, quantidade)
	values(@numnota, @codprod, @quantidade)
	if @@ROWCOUNT > 0
		begin
			update NF_VENDA
			set valortotal = valortotal + (@quantidade * (select preco from Produto where codproduto = @codprod))
			where numnota = @numnota
			if @@ROWCOUNT > 0
				begin
					update Produto
					set qntestoque = qntestoque - @quantidade
					where codproduto = @codprod
					if @@ROWCOUNT > 0
						begin
							commit transaction
							return 1
						end
				end
			else
				begin
					rollback transaction
					return 0
				end
		end
	else
		begin
			rollback transaction
			return 0
		end


/* Alterar status do cliente */
create procedure alt_status_cliente
@nome_cli varchar(40),
@fidelidade char(1),
@premium char(1)
as
begin transaction
	declare @cod numeric(12,0)
	set @cod = (select codpessoa from Pessoa where nome = @nome_cli)
	if not exists (select codpessoa from Pessoa where nome = @nome_cli)
	begin
		rollback transaction
		print 'Não há cliente com esse nome'
	end
	update Cliente
	set cliente_fidelidade = @fidelidade, cliente_premium = @premium
	where codpessoa = @cod
	if @@ROWCOUNT > 0
		begin
			commit transaction
			return 1
		end
	else
		begin
			rollback transaction
			return 0
		end



/* Finalizar Venda */
create procedure finalizar_venda
@numnota numeric(12,0),
@numfatura numeric(12,0)
as
begin transaction
	insert into Fatura
	values(@numfatura, (select valortotal from NF_VENDA where numnota = @numnota), DATEADD(month, 1, (select data from NF_VENDA where numnota = @numnota)), null, 0)
	if @@ROWCOUNT > 0
		begin
			insert into Fatura_venda
			values(@numfatura, @numnota)
			if @@ROWCOUNT > 0
				begin
					commit transaction
					return 1
				end
			else
				begin
					rollback transaction
					return 0
				end
		end
	else
		begin
			rollback transaction
			return 0
		end
			
/* Gerar Fatura Produto comprado */
create procedure fatura_compra_prod
@numnota_prod numeric(12,0),
@numfatura numeric(12,0)
as
begin transaction
insert into Fatura
values(@numfatura, (select valortotal from NF_COMPRA_PROD where numnota_prod = @numnota_prod), DATEADD(month, 1, (select data from NF_COMPRA_PROD where numnota_prod = @numnota_prod)), null, 1)
if @@ROWCOUNT > 0
	begin
		insert into Fatura_Compraprod
		values(@numfatura, @numnota_prod)
		if @@ROWCOUNT > 0
			begin
				commit transaction
				return 1
			end
		else
			begin
				rollback transaction
				return 0
			end
	end
else
	begin
		rollback transaction
		return 0
	end

	

/* Gerar Fatura Insumo comprado */
create procedure fatura_compra_insumo
@numnota_insumo numeric(12,0),
@numfatura numeric(12,0)
as
begin transaction
insert into Fatura
values(@numfatura, (select valortotal from NF_COMPRA_INSUMO where numnota_insumo = @numnota_insumo), DATEADD(month, 1, (select data from NF_COMPRA_INSUMO where numnota_insumo = @numnota_insumo)), null, 2)
if @@ROWCOUNT > 0
	begin
		insert into Fatura_Comprainsumo
		values(@numfatura, @numnota_insumo)
		if @@ROWCOUNT > 0
			begin
				commit transaction
				return 1
			end
		else
			begin
				rollback transaction
				return 0
			end
	end
else
	begin
		rollback transaction
		return 0
	end

	


/* Realizar pagamento */
create procedure pagar_fatura
@numfatura numeric(12,0),
@forma_pgto varchar(20)
as
begin transaction
	update Fatura
	set dtpagamento = (select convert (date, getdate()))
	where numfatura = @numfatura
	if @@ROWCOUNT > 0
		begin
			update Fatura_paga
			set forma_pgto = @forma_pgto
			where numfatura = @numfatura
			if @@ROWCOUNT > 0
				begin
					commit transaction
					return 1
				end
			else
				begin
					rollback transaction
					return 0
				end	
		end
		else
			begin
				rollback transaction
				return 0
			end	 

/* Compra insumo */
create procedure compra_insumo
@numnota_insumo numeric(12,0),
@nome varchar(50),
@quantidade int,
@preco money,
@dtfabricacao date,
@dtvencimento date,
@codfornecedor numeric(12,0),
@codinsumo numeric(12,0)
as
begin transaction
	if not exists (select * from Insumo where codinsumo = @codinsumo)
	begin
		insert into Insumo
		values(@codinsumo, @nome, 0, @preco, @dtfabricacao, @dtvencimento)
	end
	insert into NF_COMPRA_INSUMO(numnota_insumo, valortotal, data, quantidade, status, codpessoa, codinsumo)
	values(@numnota_insumo, (@quantidade * (select preco from Insumo where codinsumo = @codinsumo)), GETDATE(), @quantidade, 1, @codfornecedor, @codinsumo)
	if @@ROWCOUNT > 0
		begin
			commit transaction
			return 1
		end
	else 
		begin
			rollback transaction
			return 0
		end

/* Cadastro produto insdustrial */
create procedure cadastro_prod_industrial
@codproduto numeric(12,0),
@nome varchar(50),
@preco money,
@qntestoque int,
@dtfabricacao date,
@dtvencimento date
as
begin transaction
	insert into Produto(codproduto, nome, preco, qntestoque, dtfabricacao, dtvencimento, tipo)
	values(@codproduto, @nome, @preco, @qntestoque, @dtfabricacao, @dtvencimento, 1)
	if @@ROWCOUNT > 0
		begin
			insert into Produto_Industrial(codproduto)
			values(@codproduto)
			if @@ROWCOUNT > 0
			begin
				commit transaction
				return 1
			end
		end
	else
		begin
			rollback transaction
			return 0
		end


/* Compra produto */
create procedure compra_produto_industrial
@numnota_prod numeric(12,0),
@nome varchar(50),
@quantidade int,
@preco money,
@dtfabricacao date,
@dtvencimento date,
@codfornecedor numeric(12,0),
@codproduto numeric(12,0)
as
begin transaction
	if not exists (select * from Produto where codproduto = @codproduto)
	begin
		declare @var int
		exec @var = cadastro_prod_industrial @codproduto, @nome, @preco, 0, @dtfabricacao, @dtvencimento
		print @var
	end
	insert into NF_COMPRA_PROD(numnota_prod, valortotal, data, quantidade, status, codpessoa, codprod)
	values(@numnota_prod, (@quantidade * (select preco from Produto where codproduto = @codproduto)), GETDATE(), @quantidade, 1, @codfornecedor, @codproduto)
	if @@ROWCOUNT > 0
		begin
			commit transaction
			return 1
		end
	else 
		begin
			rollback transaction
			return 0
		end




/* Cadastrar promocao para produto */
create procedure cadastrar_promoproduto
@codpromo numeric(12,0),
@dtinicio date,
@dtfim date,
@codprod numeric(12,0),
@desconto int
as
begin transaction
	insert into Promocao
	values(@codpromo, @dtinicio, @dtfim)
	if @@ROWCOUNT > 0
		insert into prodpromocao
		values(@codpromo, @codprod, @desconto)
		if @@ROWCOUNT > 0
			begin
				commit transaction
				return 1
			end
		else
			begin
				rollback transaction
				return 0
			end



-- *********************************************************************************
-- SCRIPT: Manipulacao Database - EXEC's
-- *********************************************************************************

	-- EXECUCAO cadastro_fornecedor
	declare @ret int
	exec @ret = cadastro_fornecedor 1, 'Marcos Pontes', 'R. Jasmins', 152, 8746512, 233215468, 'Supermercado do Bairro'
	print @ret

	-- EXECUCAO cadastro_cliente
	declare @ret int
	exec @ret = cadastro_cliente 2, 'Matheus Bruder', 'R. Esmeralda', 152, 8746512, 233215468, '1999-03-24', 997004045, 'm@bol.com'
	print @ret

	-- EXECUCAO alt_status_cliente
	declare @ret int
	exec @ret = alt_status_cliente 'Matheus Bruder', 'S', 'S'
	print @ret

	-- EXECUCAO cadastro_colaborador
	declare @ret int
	exec @ret = cadastro_colaborador 3, 'Joao da Silva', 'R. Mar', 46, 945651, 161516, '2000-05-24', 997004045, 'm@bol.com', 'joao', '123', '2000'
	print @ret

	-- EXECUCAO compra_insumo
	declare @ret int
	exec @ret = compra_insumo 1, 'Farinha de Trigo', 10, '3.5', '2019-10-29', '2020-03-29', 1, 1
	print @ret

	-- EXECUCAO fatura_compra_insumo
	declare @ret int
	exec @ret = fatura_compra_insumo 1, 1   
	print @ret

	-- EXECUCAO cadastro_prod_fabricado
	declare @ret int
	exec @ret = cadastro_prod_fabricado 1, 1, 5, 'Coxinha de frango', '15', 500, '2019-11-12'
	print @ret

	-- EXECUCAO compra_produto_industrial
	declare @ret int
	exec @ret = compra_produto_industrial 1, 'Pepsi', 100, '2.5', '2019-07-03', '2019-09-03', 1, 2
	print @ret

	-- EXECUCAO fatura_compra_prod
	declare @ret int
	exec @ret = fatura_compra_prod 1, 2
	print @ret

	-- EXECUCAO cadastrar_promoproduto
	declare @ret int
	exec @ret = cadastrar_promoproduto 1, '2019-11-12', '2019-12-15', 1, 3 
	print @ret
	
	-- EXECUCAO venda = Criar NF
	declare @ret int
	exec @ret = venda 1, 1, 10, 2, 3
	print @ret

	-- EXECUCAO finalizar_venda = Gerar Fatura com dtpagamento NULL
	declare @ret int
	exec @ret = finalizar_venda 1, 3
	print @ret

	-- EXECUCAO pagar_fatura
	declare @ret int
	exec @ret = pagar_fatura 3, 'Crédito'
	print @ret


		select * from produto
		select * from promocao
		select * from NF_VENDA
		select * from NF_COMPRA_PROD
		select * from NF_COMPRA_INSUMO

		select * from Fatura
		select * from Fatura_paga
		
		select * from Pessoa
		select * from Pessoa_Fisica
		select * from Cliente
		select * from Colaborador

		select * from Produto
		select * from Produto_Fabricado
		select * from Produto_Industrial