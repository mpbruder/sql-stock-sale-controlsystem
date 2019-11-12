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
	@codpessoa int,
	@nome varchar(40),
	@rua varchar(50),
	@numero int,
	@cep int,
	@cnpj int,
	@razaosocial varchar(40)
	as
	begin transaction
		insert into Pessoa(codpessoa, nome,	rua, numero, cep, tipo)
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
	@codpessoa int,
	@nome varchar(40),
	@rua varchar(50),
	@numero int,
	@cep int
	as
	begin transaction
		insert into Pessoa(codpessoa, nome,	rua, numero, cep, tipo)
		values(@codpessoa, @nome, @rua, @numero, @cep, 1)
		if @@ROWCOUNT > 0
			begin
				if not exists (select * from Pessoa_Fisica where codpessoa = @codpessoa)
				begin
					insert into Pessoa_Fisica
					values(@codpessoa, )
					if @@ROWCOUNT = 0
						begin 
							rollback transaction
							return 0
						end
				end
