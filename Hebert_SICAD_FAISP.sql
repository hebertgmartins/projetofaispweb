----------------------------------------------------------
-- PROJETO SICAD FAISP
-- 2018 
-- HEBERT GONÇALVES MARTINS
--
----------------------------------------------------------
IF OBJECT_ID('TbHebert_Alunos') IS NULL
BEGIN
	CREATE TABLE TbHebert_Alunos
	(
		ID_ALUNO				INTEGER IDENTITY(1,1) CONSTRAINT PK_ID_ALUNO PRIMARY KEY,
		NOME_COMPLETO			VARCHAR(255) NOT NULL,
		DATA_DE_NASCIMENTO		VARCHAR(10) NOT NULL,
		IDADE					INTEGER NULL,
		OBJETIVO_DA_GRADUACAO	VARCHAR(1000) NULL,
		ID_GENERO			    INTEGER,
		EMAIL					VARCHAR(100)  NOT NULL
	)
END
GO


IF OBJECT_ID('TbHebert_Genero') IS NULL
BEGIN
	CREATE TABLE TbHebert_Genero 
	(
		ID_GENERO				INTEGER IDENTITY(1,1) CONSTRAINT PK_ID_GENERO PRIMARY KEY,
		DESCRICAO_GENERO		VARCHAR(30),
	)
END
GO


IF NOT EXISTS( SELECT * FROM SYS.foreign_keys WHERE parent_object_id = OBJECT_ID('TbHebert_Alunos') AND name = 'ID_GENERO' ) 
BEGIN
	ALTER TABLE TbHebert_Alunos 
	ADD CONSTRAINT ID_GENERO FOREIGN KEY(ID_GENERO) REFERENCES TbHebert_Genero(ID_GENERO)
END
GO


IF NOT EXISTS( SELECT * FROM TbHebert_Genero WHERE DESCRICAO_GENERO = 'FEMININO' )
BEGIN
	INSERT INTO TbHebert_Genero( DESCRICAO_GENERO ) VALUES('FEMININO')
END
GO

IF NOT EXISTS( SELECT * FROM TbHebert_Genero WHERE DESCRICAO_GENERO = 'MASCULINO' )
BEGIN
	INSERT INTO TbHebert_Genero( DESCRICAO_GENERO ) VALUES('MASCULINO')
END
GO


IF OBJECT_ID('MOSTRAR_GENEROS') IS NOT NULL
BEGIN
	DROP PROCEDURE MOSTRAR_GENEROS
END
GO

CREATE PROCEDURE MOSTRAR_GENEROS
AS
BEGIN

	SELECT * FROM TbHebert_Genero
END
GO

IF OBJECT_ID('INSERIR_GENEROS') IS NOT NULL
BEGIN
	DROP PROCEDURE INSERIR_GENEROS
END
GO

IF OBJECT_ID('INSERIR_GENEROS') IS NOT NULL
BEGIN
	DROP PROCEDURE INSERIR_GENEROS
END
GO

CREATE PROCEDURE INSERIR_GENEROS
(
	@NOVO_GENERO VARCHAR(30)
)
AS
BEGIN
SET NOCOUNT ON

	DECLARE @IDGERADO INTEGER


	IF NOT EXISTS( SELECT * FROM TbHebert_Genero WHERE DESCRICAO_GENERO = @NOVO_GENERO )
		BEGIN
			INSERT INTO TbHebert_Genero (DESCRICAO_GENERO) VALUES (@NOVO_GENERO)

			SET @IDGERADO = @@IDENTITY

			PRINT 'Novo gênero cadastrado com sucesso: ' + @NOVO_GENERO +
				  '- ID cadastrado automaticamente: ' + CAST(@IDGERADO AS VARCHAR(20))
		END
	ELSE
		BEGIN
			SELECT @IDGERADO = ID_GENERO 
			FROM TbHebert_Genero 
			WHERE DESCRICAO_GENERO = @NOVO_GENERO 

			PRINT 'O gênero informado já existe: ' + @NOVO_GENERO + 
				  '- ID existente: ' + CAST(@IDGERADO AS VARCHAR(20))

		END
END
GO

IF OBJECT_ID('VERIFICA_SE_NAO_TEM_NUMERO') IS NOT NULL
BEGIN
	DROP FUNCTION VERIFICA_SE_NAO_TEM_NUMERO
END
GO

CREATE FUNCTION VERIFICA_SE_NAO_TEM_NUMERO
(
	@TEXTO_A_VALIDAR VARCHAR(255)
)
RETURNS VARCHAR(30)
AS
BEGIN
	DECLARE @TEXTO_APENAS VARCHAR(30)
	
	SELECT @TEXTO_APENAS =
		CASE 
			WHEN @TEXTO_A_VALIDAR LIKE '%[0-9]%' 
			THEN 'POSSUI NUMEROS' 
			ELSE 'NÃO POSSUI NUMEROS' 
		END

	-- RETORNA: 0 --> POSSUI NÚMEROS NO TEXTO INFORMADO 
	-- RETORNA: 1 --> SOMENTE TEXTO( NÃO POSSUI NO TEXTO INFORMADO
	RETURN @TEXTO_APENAS
END
GO

-- ---------------------------------------------------------------
-- REGRA DE NEGÓCIO 4 - RETORNAR CARACTERES RESTANTES
-- ---------------------------------------------------------------
-- ---------------------------------------------------------------
-- CRIA FUNÇÃO QUE RETORNA QUANTIDADE RESTANTES DISPONÍVES: 
-- ---------------------------------------------------------------
IF OBJECT_ID('QUANTO_NUM_FALTAM') IS NOT NULL
BEGIN
	DROP FUNCTION QUANTO_NUM_FALTAM
END
GO

CREATE FUNCTION QUANTO_NUM_FALTAM
(
	@TEXTO_DIGITADO VARCHAR(1000),
	@QUANTIDADE_LIMITE INTEGER
)
RETURNS INTEGER
AS
BEGIN
	DECLARE @QUANTIDADE_DIGITADA INTEGER
	DECLARE @TOTAL_RESTANTE INTEGER

	SELECT @QUANTIDADE_DIGITADA = LEN( @TEXTO_DIGITADO )

	SET @TOTAL_RESTANTE = @QUANTIDADE_LIMITE - @QUANTIDADE_DIGITADA
	
	RETURN @TOTAL_RESTANTE
END
GO


IF OBJECT_ID('RETORNA_INFO_ALUNOS') IS NOT NULL
BEGIN
	DROP PROCEDURE RETORNA_INFO_ALUNOS
END
GO

CREATE PROCEDURE RETORNA_INFO_ALUNOS
(
	@NOME VARCHAR(255) = ''
)
AS
BEGIN
	IF @NOME = ''
		BEGIN
			SELECT * FROM TbHebert_Alunos
		END
	ELSE
		BEGIN
			SELECT * FROM TbHebert_Alunos WHERE NOME_COMPLETO LIKE '%'+ @NOME + '%'
		END
END

GO


IF OBJECT_ID('INSERIR_INFO_ALUNOS') IS NOT NULL
BEGIN
	DROP PROCEDURE INSERIR_INFO_ALUNOS
END
GO

CREATE PROCEDURE INSERIR_INFO_ALUNOS
(
	@NOME_COMPLETO			VARCHAR(255),
	@DATA_DE_NASCIMENTO		VARCHAR(10),
	@IDADE					INTEGER,
	@OBJETIVO_DA_GRADUACAO	VARCHAR(1000),
	@ID_GENERO				INTEGER,
	@EMAIL					VARCHAR(100)
)
AS
BEGIN
SET NOCOUNT ON

	IF ISNULL( LTRIM(RTRIM(@NOME_COMPLETO)), '' ) = '' 
		BEGIN
			-- ---------------------------------------------------------------
			-- SE NOME FOR NULO OU VAZIO, RETORNA ERRO:
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo [Nome Completo] deve ser preenchido.'

			
			RETURN
		END

	-- ---------------------------------------------------------------
	-- SE O CAMPO "DATA_DE_NASCIMENTO" FOR NULO OU VAZIO, RETORNA ERRO:
	-- ---------------------------------------------------------------
	IF ISNULL( LTRIM(RTRIM(@DATA_DE_NASCIMENTO)), '' ) = '' 
		BEGIN
			-- ---------------------------------------------------------------
			-- SE DATA DE NASCIMENTO FOR NULO OU VAZIO, RETORNA ERRO:
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo [Data de Nascimento] deve ser preenchido.'


			RETURN
		END

	-- ---------------------------------------------------------------
	-- SE O CAMPO "ID_GENERO" FOR NULO OU VAZIO, RETORNA ERRO:
	-- ---------------------------------------------------------------
	IF ISNULL( @ID_GENERO, 0 ) <= 0 
		BEGIN
			-- ---------------------------------------------------------------
			-- SE DATA DE NASCIMENTO FOR NULO OU VAZIO, RETORNA ERRO:
			-- ---------------------------------------------------------------
			PRINT 'Erro: o Id do Gênero deve ser informado.'

			RETURN
		END

	-- ----------------------------------------------------------------
	-- REGRA DE NEGÓCIO 2
	-- ----------------------------------------------------------------
	-- NÃO DEVERÁ SER ACEITO NÚMEROS NO CAMPO [NOME_COMPLETO]
	-- ----------------------------------------------------------------
	DECLARE @TEXTO_APENAS VARCHAR(30)

	EXECUTE @TEXTO_APENAS = VERIFICA_SE_NAO_TEM_NUMERO @NOME_COMPLETO

	IF @TEXTO_APENAS = 'POSSUI NUMEROS'
		BEGIN
			-- ---------------------------------------------------------------
			-- SE EXISTE NUMEROS NO CAMPO NOME COMPLETO RETORNA ERRO:
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo Nome Completo deve ser preenchido sem números'


			RETURN
		END

	-- -----------------------------------------------------------------------
	-- VALIDA FORMATO DATA ( DD/MM/AAAA
	-- -----------------------------------------------------------------------
	DECLARE @DATA_INVALIDA BIT
	SET @DATA_INVALIDA = 0

	IF ISNUMERIC(LEFT(@DATA_DE_NASCIMENTO, 2)) = 0
		BEGIN
			SET @DATA_INVALIDA = 1
		END 
	
	IF ISNUMERIC(SUBSTRING(@DATA_DE_NASCIMENTO, 4, 2 )) = 0
		BEGIN
			SET @DATA_INVALIDA = 1
		END 

	IF ISNUMERIC(RIGHT(@DATA_DE_NASCIMENTO, 4 )) = 0
		BEGIN
			SET @DATA_INVALIDA = 1
		END 

	IF SUBSTRING(@DATA_DE_NASCIMENTO, 3, 1 ) != '/'
		BEGIN
			SET @DATA_INVALIDA = 1
		END

	IF SUBSTRING(@DATA_DE_NASCIMENTO, 6, 1 ) != '/'
		BEGIN
			SET @DATA_INVALIDA = 1
		END

	IF @DATA_INVALIDA = 1
		BEGIN
			-- ---------------------------------------------------------------
			-- SE ALGUMA DAS VALIDACOES FOI POSITIVA, RETORNA ERRO
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo Data de Nascimento está fora do padrão DD/MM/AAAA.'


			RETURN
		END

	-- POSSIBILIDADE DE VALIDAR SE DIGITOS DO MÊS ENTRE 1 E 12

	-- POSSIBILIDADE DE VALIDAR SE DIGITOS DO MÊS ENTRE 1 E 31

	-- -----------------------------------------------------------------------
	-- REGRA DE NEGÓCIO 3:
	-- -----------------------------------------------------------------------
	-- NUMERO DE CARACTERES POSSÍVEIS É (10) SENDO 8 NUMEROS E 2 ALFANUMERICOS(/)
	-- -----------------------------------------------------------------------

	IF LEN(@DATA_DE_NASCIMENTO) != 10
		BEGIN
			-- ---------------------------------------------------------------
			-- SE DATA DE NASCIMENTO FOR MENOR QUE 1950, RETORNA ERRO
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo Data de Nascimento informado deve conter 10 caracteres( DD/MM/AAAA ).'

			RETURN
		END

	-- -----------------------------------------------------------------------
	-- REGRA DE NEGÓCIO 3:
	-- -----------------------------------------------------------------------
	-- MENOR DATA A SER ACEITA É 01/01/2015
	-- -----------------------------------------------------------------------

	IF RIGHT(@DATA_DE_NASCIMENTO, 4 ) < 1950
		BEGIN
			-- ---------------------------------------------------------------
			-- SE DATA DE NASCIMENTO FOR MENOR QUE 1950, RETORNA ERRO
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo Data de Nascimento informado deve ser maior que 01/01/1950.'


			RETURN
		END

	-- -----------------------------------------------------------------------
	-- REGRA DE NEGÓCIO 4:
	-- -----------------------------------------------------------------------
	-- A IDADE DEVERÁ SER CALCULADA AUTOMATICAMENTE
	-- -----------------------------------------------------------------------
	
	DECLARE @DATA_CONVERTIDA VARCHAR(10)
	SET @DATA_CONVERTIDA = RIGHT(@DATA_DE_NASCIMENTO, 4) + '-' + 
							  SUBSTRING(@DATA_DE_NASCIMENTO, 4, 2 )+ '-' +
							  LEFT(@DATA_DE_NASCIMENTO, 2)   
							  	
	-- SELECT @DATA_CONVERTIDA 
	SET @IDADE = DATEDIFF( YEAR, @DATA_CONVERTIDA  , GETDATE() )
	-- SELECT @IDADE 
	-- -----------------------------------------------------------------------
	-- VALIDA SE O ID DO GÊNERO INFORMADO COINCIDE COM A TABELA DE GENEROS
	-- -----------------------------------------------------------------------
	IF NOT EXISTS( SELECT * FROM TbHebert_Genero WHERE ID_GENERO = @ID_GENERO )
		BEGIN
			-- ---------------------------------------------------------------
			-- SE ALGUMA DAS VALIDACOES FOI POSITIVA, RETORNA ERRO
			-- ---------------------------------------------------------------
			PRINT 'ERRO DE SISTEMA: o campo ID_GENERO informado deve existir na tabela TbHebert_Genero'

		
			RETURN
		END
	
	
	BEGIN TRY
		INSERT INTO [TbHebert_Alunos]
		(
			NOME_COMPLETO,
			DATA_DE_NASCIMENTO,
			IDADE,
			OBJETIVO_DA_GRADUACAO,
			ID_GENERO,
			EMAIL
		)
		VALUES
		(
			@NOME_COMPLETO,
			@DATA_DE_NASCIMENTO,
			@IDADE,
			@OBJETIVO_DA_GRADUACAO,
			@ID_GENERO,
			@EMAIL
		)

		PRINT 'Registro inserido com sucesso na tabela [TbHebert_Alunos] com o Id:' + CAST( @@IDENTITY AS VARCHAR(20) )

	END TRY
	BEGIN CATCH
		-- ---------------------------------------------------------------
		-- SE ALGUMA DAS VALIDACOES FOI POSITIVA, RETORNA ERRO
		-- ---------------------------------------------------------------
		SELECT ERROR_MESSAGE()
		
	END CATCH	

END
GO

/*
	
	SELECT * FROM TbHebert_Alunos
	SELECT * FROM TbHebert_Genero

	SELECT dbo.VERIFICA_SE_NAO_TEM_NUMERO ('TESTE')
	SELECT dbo.VERIFICA_SE_NAO_TEM_NUMERO ('TESTE125')
	SELECT dbo.QUANTO_NUM_FALTAM( 'Hebert Gonçalves Martins' , 1000 )
	
	DECLARE @RETURNED VARCHAR(MAX)
	EXECUTE @RETURNED = VERIFICA_SE_NAO_TEM_NUMERO 'VALIDAS  4444'
	SELECT @RETURNED 

	EXECUTE MOSTRAR_GENEROS
	EXECUTE INSERIR_GENEROS 'BISEXUAL'

	EXECUTE RETORNA_INFO_ALUNOS

	EXECUTE INSERIR_INFO_ALUNOS
		@NOME_COMPLETO			= '',
		@DATA_DE_NASCIMENTO		= '21/08/1983',
		@IDADE					= 25,
		@OBJETIVO_DA_GRADUACAO	= 'TESTAR A PROCEDURE' ,
		@ID_GENERO			= 20,
		@EMAIL					 = 'TESTE@TESTE.COM.BR'

	
	EXECUTE INSERIR_INFO_ALUNOS
		@NOME_COMPLETO			= 'TESTE 2222',
		@DATA_DE_NASCIMENTO		= '21/08/1983',
		@IDADE					= NULL,
		@OBJETIVO_DA_GRADUACAO	= 'TESTAR A PROCEDURE' ,
		@ID_GENERO			= 2,
		@EMAIL					 = 'TESTE@TESTE.COM.BR'

	EXECUTE INSERIR_INFO_ALUNOS
		@NOME_COMPLETO			= 'TESTE',
		@DATA_DE_NASCIMENTO		= '21-08-1983',
		@IDADE					= NULL,
		@OBJETIVO_DA_GRADUACAO	= 'TESTAR A PROCEDURE' ,
		@ID_GENERO			= 2,
		@EMAIL					 = 'TESTE@TESTE.COM.BR'

	EXECUTE INSERIR_INFO_ALUNOS
		@NOME_COMPLETO			= 'Hebert Martins',
		@DATA_DE_NASCIMENTO		= '22/02/1987',
		@IDADE					= 31,
		@OBJETIVO_DA_GRADUACAO	= 'Sobra e Agua fresca' ,
		@ID_GENERO			= 1,
		@EMAIL				='hebert@teste'


	DECLARE @OBJETIVO_DA_GRADUACAO VARCHAR(2000)= REPLICATE('A', 1050)
	EXECUTE INSERIR_INFO_ALUNOS
		@NOME_COMPLETO			= 'TESTE',
		@DATA_DE_NASCIMENTO		= '21/08/1983',
		@IDADE					= NULL,
		@OBJETIVO_DA_GRADUACAO	= @OBJETIVO_DA_GRADUACAO ,
		@ID_GENERO			= 2,
		@EMAIL					 = 'TESTE@TESTE.COM.BR'

	SELECT LEN(OBJETIVO_DA_GRADUACAO) FROM TbHebert_Alunos WHERE ID_ALUNO = 5 
	
	EXECUTE INSERIR_INFO_ALUNOS
		@NOME_COMPLETO			= 'TESTE',
		@DATA_DE_NASCIMENTO		= '21/08/1983',
		@IDADE					= 25,
		@OBJETIVO_DA_GRADUACAO	= 'TESTAR A PROCEDURE' ,
		@ID_GENERO			= 20,
		@EMAIL					 = 'TESTE@TESTE.COM.BR'


*/