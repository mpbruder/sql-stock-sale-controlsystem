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
-- SCRIPT: Manipulacao Database 
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
	-- EXECUCAO
	declare @ret int
	exec @ret = cadastro_fornecedor 121, 'Marcos Pontes', 'R. Jasmins', 152, 8746512, 233215468, 'Supermercado do Bairro'
	print @ret


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

	-- EXECUCAO cadastro_cliente
	declare @ret int
	exec @ret = cadastro_cliente 121, 'Matheus Bruder', 'R. Esmeralda', 152, 8746512, 233215468, '1999-03-24', 997004045, 'm@bol.com'
	print @ret




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

	-- EXECUCAO cadastro_colaborador
	declare @ret int
	exec @ret = cadastro_colaborador 121, 'Matheus Bruder', 'R. Esmeralda', 152, 8746512, 233215468, '1999-03-24', 997004045, 'm@bol.com', 'theuso', '123', '1000'
	print @ret