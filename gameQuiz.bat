@echo off
mode 85,25
color E0
title Jogo de Perguntas
chcp 65001 > nul



rem Parte em que o usuário digita o nome
:digitarNome
cls
call:cabecalho
echo. 
set /p nome=Digite seu nome: 
goto:mostrarMenuPrincipal

rem Cabeçalho do jogo
:cabecalho
echo -------------------------------------------------------------------------------------
echo                                  JOGO DE PERGUNTAS
echo                            Feito por: Lucas Macêdo da Silva
echo -------------------------------------------------------------------------------------
goto:eof



rem Tela de Menu Principal para o usuário interagir na tela
:mostrarMenuPrincipal
cls
call:cabecalho
echo Bem Vindo(a) %nome% - Menu Principal
echo -------------------------------------------------------------------------------------
echo. 
echo Escolha um dos números correspondentes aos itens abaixo
echo.
echo [1] Jogar
echo [2] Regras
echo [3] Mudar Nome
echo [4] Sair
echo.
set /p op=Digite uma opção: 
if not defined op (
    goto mostrarMenuPrincipal
)
if %op%==1 (
	goto:iniciarJogo
) else if %op%==2 (
	goto:regrasDoGame
) else if %op%==3 (
	goto:digitarNome
) else if %op%==4 (
	goto:sairDoGame
) else (
	goto:mostrarMenuPrincipal
)



rem Usuário deve confirmar se quer sair mesmo ou não
:sairDoGame
cls
call:cabecalho
echo Bem Vindo(a) %nome% - Sair
echo -------------------------------------------------------------------------------------
echo.
echo Você selecionou a opção 3 (Sair)
choice /n /M "Deseja sair mesmo? [S/N]: "
if %errorlevel%==1 (
	exit /b
) else (
	goto:mostrarMenuPrincipal
)



rem Somente para mostrar as regras ao usuário
:regrasDoGame
cls
call:cabecalho
echo Bem Vindo(a) %nome% - Sair
echo -------------------------------------------------------------------------------------
echo.
echo Regras do Game:
echo.
echo 1- Serão fornecidas 10 questões para responder
echo 2- Serão fornecidas 4 alternativas para o usuário escolher
echo 3- O usuário poderá pular somente duas vezes
echo 4- A resposta de cada pergunta será dada após o usuário responder
echo 5- Cada pergunta certa, o usuário ganha 1 ponto
echo 6- Você poderá jogar novamente após o término da partida
pause | more > nul
goto:mostrarMenuPrincipal



rem Inicializando o jogo para o usuário
:iniciarJogo
setlocal enabledelayedexpansion
cls
call:cabecalho
echo Bem Vindo(a) %nome% - Quiz
echo -------------------------------------------------------------------------------------
echo.
::     Contadores
::     [0] - Perguntas
::     [1] - Respostas
::     [2] - Alternativas
::     [3] - Listagem sorteio das perguntas feitas
::     [4] - Mostrar perguntas
::     [5] - Listagem sorteio das alternativas
for /L %%c in (0,1,5) do (
	set /a cont[%%c]=0
)
::pegando o arquivo de texto e dividindo as perguntas, respostas e alternativas
for /F "tokens=*" %%q in (Perguntas.txt) do (
	set "lin=%%q"
	
	if "!lin:~0,2!"=="P:" (
		set pergunta[!cont[0]!]=!lin:~2!
		set /a "cont[0]+=1"
	)
	
	if "!lin:~0,2!"=="R:" (
		set resposta[!cont[1]!]=!lin:~2!
		set /a "cont[1]+=1"
	)
	
	if "!lin:~0,2!"=="A:" (
		set alternativa[!cont[2]!]=!lin:~2!
		set /a "cont[2]+=1"
	)
)
::usuário pode pular 2 vezes
set /a pular=2
::zerando o placar
set /a pontos=0
::Realizando o sorteio de perguntas
for /L %%p in (0,1,9) do (
	call:sortearPerguntas
	call:realizarQuestao
)
goto:resultadoFinal



rem Fazendo o sorteio das perguntas evitando repetição
:sortearPerguntas
set /a sorteio=!random! %% !cont[0]!
::Verificando se a pergunta ja foi feita
for /L %%s in (0,1,!cont[3]!) do (
	if !pegarDif[%%s]!==!pergunta[%sorteio%]! (
		goto:sortearPerguntas
	)
)
::caso tenha passado na verificação, inserimos na variável
set pegarDif[%cont[3]%]=!pergunta[%sorteio%]!
set /a "cont[3]+=1"
::resposta também está incluida
set respCorreta=!resposta[%sorteio%]!
::zerando a variável para o sorteio da alternativa ser inicializado
set /a cont[5]=0
::fazendo o sorteio das alternativas (laço for pois são 4 alternativas)
for /L %%i in (0,1,3) do (
	call:alternativasSorteio
)
call:atualizarResposta
goto:eof



rem As alternativas também precisam ser sorteadas para não ter uma ordem especifica
:alternativasSorteio
::mirando as alternativas de acordo com o sorteio realizado
set /a alt=%sorteio%*4
::sorteando um valor aleatório dentre 4 opções
set /a aux=!random! %%4
::buscando as 4 opções
for /L %%i in (0,1,3) do (
	::mirando o indice
	set /a indice=%alt%+%%i
	::buscando dentro do indice 
	for %%x in (!indice!) do (
		::setando o valor
		set vetorAlt[%%i]=!alternativa[%%x]!
	)
)
::fazendo agora o sorteio das alternativas
for /L %%i in (0,1,!cont[5]!) do (
	if !alterRandom[%%i]!==!vetorAlt[%aux%]! (
		goto:alternativasSorteio
	)
)
set alterRandom[!cont[5]!]=!vetorAlt[%aux%]!
set /a "cont[5]+=1"
goto:eof



rem Atualizando a resposta para o lugar correto
:atualizarResposta
::atribuindo valor numérico de acordo com a letra selecionada
if /i "%respCorreta%"=="A" (
	set /a numResp=0
) else if /i "%respCorreta%"=="B" (
	set /a numResp=1
) else if /i "%respCorreta%"=="C" (
	set /a numResp=2
) else (
	set /a numResp=3
)
::atribuindo resposta correta a um auxVetor
for /L %%i in (0,1,3) do (
	if !numResp!==%%i (
		set auxVetor=!vetorAlt[%%i]!
	)
)
::procurando resposta correta numa alternativa randomizada
for /L %%j in (0,1,3) do (
	if !auxVetor!==!alterRandom[%%j]! (
		set numResp=%%j
	)
)
::atribuindo resposta correta a uma letra
if !numResp!==0 (
	set respCorreta=A
) else if !numResp!==1 (
	set respCorreta=B
) else if !numResp!==2 (
	set respCorreta=C
) else (
	set respCorreta=D
)
goto:eof



rem Mostrando a pergunta e as alternativas para o usuário
:realizarQuestao
cls
call:cabecalho
echo Bem Vindo(a) %nome% - Quiz
echo -------------------------------------------------------------------------------------
echo Quantidade Perguntas Corretas: %pontos% - Quantidade de Pulos: %pular%
echo.
::mostrando a pergunta
echo !pegarDif[%cont[4]%]!
echo.
::mostrando as 4 alternativas
echo A) !alterRandom[0]!
echo B) !alterRandom[1]!
echo C) !alterRandom[2]!
echo D) !alterRandom[3]!
set /a "cont[4]+=1"
::o usuário deverá responder com a letra correta
echo.
echo Responda com P caso queira pular
echo.
set /p usuResp=Digite a resposta correta: 
if /i "%usuResp%" neq "A" if /i "%usuResp%" neq "B" if /i "%usuResp%" neq "C" if /i "%usuResp%" neq "D" if /i "%usuResp%" neq "P" (
	set /a "cont[4]-=1"
	goto:realizarQuestao
)
goto:verificarResposta
goto:eof



rem Respondendo ao usuário
:verificarResposta
cls
call:cabecalho
echo Bem Vindo(a) %nome% - Quiz
echo -------------------------------------------------------------------------------------
echo.
echo Sua Resposta: %usuResp%
echo.
echo Resposta Correta: %respCorreta%
echo.
if /i "%usuResp%"=="%respCorreta%" (
	set /a "pontos+=1"
	echo Você Acertou!
	pause | more > nul
) else if /i "%usuResp%"=="P" (
	if %pular% GTR 0 (
		set /a "pular-=1"
	) else (
		set /a "cont[4]-=1"
		call:realizarQuestao
	)
) else (
	echo Você Errou!
	pause | more > nul
)
goto:eof



rem Dando o resultado final para o usuário
:resultadoFinal
cls
call:cabecalho
echo Bem Vindo(a) %nome% - Resultado Final
echo -------------------------------------------------------------------------------------
echo.
echo Parabéns pela dedicação ao nosso quiz, esse é o resultado final:
echo Acertos: %pontos%
echo.
pause | more > nul
goto:mostrarMenuPrincipal