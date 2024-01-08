# **WORK IN PROGRESS**

# Tiny Library
Esta é uma **Coleção de Bibliotecas** criadas por Duckafire, para serem usadas no computador/console de fantasia [Tic80](https://tic80.com).

| Bibliotecas | Breve descrição |
| :-: | :-: |
| coli2DA | Verifica colisões entre objetos |
| === | Em breve |

---

## Como usar/ativar:
O Tic80 tem uma certa ""dificuldade"" para ler bibliotecas da maneira *tradicional*:
```
local reference = require( "path.library" )-- in lua
```
Mas não significa que ele não possar fazer (por isso existem as __*convencionais*__)). Mesmo assim, tentar usar bibliotecas de maneira convencional no Tic80, pode ser um pouco chato, é por causa disso que as bibliotecas desta coleção foram desenhadas para serem copiadas e coladas dentro dos cartuchos.

Não há segredo, basta: escolher a biblioteca desejada, sua **variante**, acessar seu arquivo neste repositório (*não precisa nem baixar*), copiar seu conteúdo e colar no seu cartucho.

Sem segredo, mas **recomendo** colá-las no topo do códico.

---

## Variantes de biblioteca
Todas as bibliotecas deste repositório estão disponíveis em três formatos: __*compactado*__, __*não compactado*__ e __*convencional*__.

---

### Compactadas **(trabalho em progresso)**
Foram pensadas para usuários que não possuem a versão *PRO* do Tic80, e que por causa disso querem economizar o máximo de espaço que conseguirem, além dos usuário que apenas querem manter seu cartucho mais limpo, sem *códigos estáticos*.

O __*!*__ antes de nome de um biblioteca indica que ela é a **versão compactada**.

---

### Não compactadas **(trabalho em progresso)**
Se você não se importa tanto com o quão grande está o seu código e/ou quer estudar as bibliotecas, a **versão não compactada** é a melhor escolha. Ela é a *base* para a **versão compactada**, e foi feita para ser o mais legível possível.

Bibliotecas que não possuem __*!*__ em seu nome, são as **versões não compactadas**.

---

### Convencional **(trabalho em progresso)**
Nestas versões, as bibliotecas estão estruturadas da maneira *padrão LUA*, ou seja, seguindo o modelo aceito pela linguagem, que permite seu uso através da função `require`. Você pode ver como usá-las no Tic80 com esse formato aqui.

[/]: # (link para o "aqui" https//../README.md)

As **versões convencionais** podem ser obtidas em: *main/Collection/Conventional/*
