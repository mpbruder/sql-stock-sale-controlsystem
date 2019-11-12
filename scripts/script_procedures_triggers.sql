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
	drop procedure cadastro_fornecedor
	create procedure cadastro_fornecedor
	@nome varchar(40),
	@rua varchar(50),
	@numero int,
	@cep int,
	@cnpj int,
	@razaosocial varchar(40)
	as
	begin transaction
		insert into Pessoa(nome, rua, numero, cep, tipo)
		values(@nome, @rua, @numero, @cep, 0)
		if @@ROWCOUNT > 0
			begin
				insert into Fornecedor(codpessoa, cnpj, razao_social)
				values(@@IDENTITY, @cnpj, @razaosocial)
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
	exec @ret = cadastro_fornecedor 'Marcos Pontes', 'R. Jasmins', 152, 8746512, 233215468, 'Supermercado do Bairro'
	print @ret




	select * from Pessoa
	select * from Pessoa_Fisica
	select * from Cliente
	/* Cadastro de Cliente */
	create procedure cadastro_cliente
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
		if not exists (select * from Pessoa where codpessoa = @@IDENTITY)
			insert into Pessoa(nome, rua, numero, cep, tipo)
			values(@nome, @rua, @numero, @cep, 1)
			if @@ROWCOUNT > 0
				begin
						insert into Pessoa_Fisica
						values(@@IDENTITY, @CPF, @dtnascimento, @telefone, @email)
						if @@ROWCOUNT = 0
							begin 
								rollback transaction
								return 0
					end
					insert into Cliente 
					values(@@IDENTITY, 0, 'N', 'N')
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