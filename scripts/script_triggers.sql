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
-- SCRIPT: Manipulacao Database - TRIGGERS
-- *********************************************************************************

 -- drop trigger att_num_compravenda
	create trigger att_num_compravenda
	on NF_VENDA for insert
	as
	update Cliente
	set numero_compras = numero_compras + 1
	where codpessoa = (select cod_cli from inserted)
	if @@ROWCOUNT = 0
		rollback transaction
	update Colaborador
	set numero_vendas = numero_vendas + 1
	where codpessoa = (select cod_col from inserted)
	if @@ROWCOUNT = 0
		rollback transaction


 -- drop trigger att_comissao
	create trigger att_comissao
	on Colaborador for update
	as
	if update(numero_vendas)
	begin
		if ((select numero_vendas from inserted) >= 100 and (select numero_vendas from inserted) < 500)
		begin
			update Colaborador
			set comissao = 5
			where codpessoa = (select codpessoa from inserted)
			if @@ROWCOUNT = 0
				rollback transaction
		end
		if ((select numero_vendas from inserted) >= 500 and (select numero_vendas from inserted) < 1000)
		begin
			update Colaborador
			set comissao = 15
			where codpessoa = (select codpessoa from inserted)
			if @@ROWCOUNT = 0
				rollback transaction
		end
		if ((select numero_vendas from inserted) >= 1000 and (select numero_vendas from inserted) < 5000)
		begin
			update Colaborador
			set comissao = 20
			where codpessoa = (select codpessoa from inserted)
			if @@ROWCOUNT = 0
				rollback transaction
		end
		if ((select numero_vendas from inserted) >= 5000)
		begin
			update Colaborador
			set comissao = 30
			where codpessoa = (select codpessoa from inserted)
			if @@ROWCOUNT = 0
				rollback transaction
		end
	end

	
 -- drop trigger att_status
	create trigger att_status
	on Cliente for update
	as
	if update(numero_compras)
	begin
		if((select numero_compras from inserted) >= 100)
		begin
			update Cliente
			set cliente_fidelidade = 'S'
			where codpessoa = (select codpessoa from inserted)
			if @@ROWCOUNT = 0
				rollback transaction
		end
		if((select numero_compras from inserted) >= 1000)
		begin
			update Cliente
			set cliente_premium = 'S'
			where codpessoa = (select codpessoa from inserted)
			if @@ROWCOUNT = 0
				rollback transaction
		end
	end


 -- drop trigger finalizar_NF_venda
	create trigger finalizar_NF_venda
	on Fatura_Venda for insert
	as
	begin
		update NF_VENDA
		set status = 0
		where numnota = (select numnota from inserted)
		if @@ROWCOUNT = 0
			rollback transaction
	end

 -- drop trigger finalizar_NF_compra_prod
	create trigger finalizar_NF_compra_prod
	on Fatura_Compraprod for insert
	as
	begin
		update NF_COMPRA_PROD
		set status = 0
		where numnota_prod = (select numnota_prod from inserted)
		if @@ROWCOUNT = 0
			rollback transaction
	end

 -- drop trigger finalizar_NF_compra_insumo
	create trigger finalizar_NF_compra_insumo
	on Fatura_Comprainsumo for insert
	as
	begin
		update NF_COMPRA_INSUMO
		set status = 0
		where numnota_insumo = (select numnota_insumo from inserted)
		if @@ROWCOUNT = 0
			rollback transaction
	end


 -- drop trigger pagamentofatura
	create trigger pagamentofatura
	on Fatura for update
	as
	if update(dtpagamento)
	begin
		declare @dtpag date
		set @dtpag = (select dtpagamento from inserted)
		if (@dtpag is null)
			rollback transaction
		else
			declare @var int
			set @var = (select  DATEDIFF(day, (select dtpagamento from inserted), (select dtvencimento from inserted)))
			if (@var < 0)
				rollback transaction
			else
				insert into Fatura_paga(numfatura, valorfatura, dtvencimento, dtpagamento, tipo)
				values((select numfatura from deleted),(select valorfatura from inserted),(select dtvencimento from inserted),(select dtpagamento from inserted),(select tipo from inserted))
				if @@rowcount = 0
					rollback transaction
	end

 -- drop trigger exclusaofatura
	create trigger exclusaofatura
	on Fatura_paga for update
	as
	if update (forma_pgto)
	declare @var int
	set @var = (select tipo from inserted)
	if @var = 0
	begin
		delete from Fatura_Venda
		where numfatura = (select numfatura from inserted)
		if @@rowcount = 0
			rollback transaction
	end
	if @var = 1
	begin
		delete from Fatura_Compraprod
		where numfatura = (select numfatura from inserted)
		if @@rowcount = 0
			rollback transaction
	end
	if @var = 2
	begin 
		delete from Fatura_Comprainsumo
		where numfatura = (select numfatura from inserted)
		if @@rowcount = 0
			rollback transaction
	end
	delete from Fatura
	where numfatura = (select numfatura from inserted)
	if @@rowcount = 0
		rollback transaction


 -- drop trigger estoque_insumo
	create trigger estoque_insumo
	on NF_COMPRA_INSUMO for insert
	as
	update Insumo
	set qntestoque = qntestoque + (select quantidade from inserted)
	where codinsumo = (select codinsumo from inserted)
	if @@ROWCOUNT = 0
		rollback transaction

 -- drop trigger estoque_prod_industrial
	create trigger estoque_prod_industrial
	on NF_COMPRA_PROD for insert
	as
	update Produto
	set qntestoque = qntestoque + (select quantidade from inserted)
	where codproduto = (select codproduto from inserted) and tipo = 1
	if @@ROWCOUNT = 0
		rollback transaction


 -- drop trigger gatilho_promocao
	create trigger gatilho_promocao
	on prodpromocao for insert
	as
	declare @var int
	set @var = DATEDIFF(day, GETDATE(), (select dtfim from Promocao where codpromo = (select codpromo from inserted)))
	if @var > 0 
		begin
			update Produto
			set preco = preco - (select desconto from inserted)
			where codproduto = (select codprod from inserted)
		end
	else
		begin
			update Produto
			set preco = preco + (select desconto from inserted)
			where codproduto = (select codprod from inserted)
		end


 -- drop trigger baixa_estoque_insumo
	create trigger baixa_estoque_insumo
	on insumoproduto for insert
	as
	update Insumo
	set qntestoque = qntestoque - (select quantidade from inserted)
	where codinsumo = (select codinsumo from inserted)
	if @@ROWCOUNT = 0
		rollback transaction

 -- drop trigger verificar_promocao
	create trigger verificar_promocao
	on NF_VENDA for update
	as
	if update(valortotal)
	begin
		declare @var int
		set @var = DATEDIFF(day, GETDATE(), (select dtfim from Promocao 
												where codpromo = (select codpromo from prodpromocao 
																	where codprod = (select codprod from itemnotafiscal 
																						where codprod = (select numnota from NF_VENDA 
																											where numnota = (select numnota from inserted))))))
		if @var < 0
			begin
				update Produto
				set preco = preco + (select desconto from prodpromocao 
										where codprod = (select codprod from itemnotafiscal
															where numnota = (select numnota from inserted)))
				where codproduto = (select codprod from itemnotafiscal
										where numnota = (select numnota from inserted))
				if @@ROWCOUNT = 0
					rollback transaction
			end
		end