# Tópicos
* Variates de bibliotecas
* Onde o Tic80 busca bibliotecas *externas*
* Como ativar/usar as bibliotecas

# Variantes de bibliotecas
Cada biblioteca presente na coleção Tiny Library possui três variantes enquivalente, onde o diferencial de cada uma delas é a
organização de seu código ou, até mesmo, a maneira de ativá-la dentro do Tic80. Abaixo estão listados os tipos de variantes
presentes nesta coleção, junto à algumas informações sobre elas.

| Variantes | Diferencial | Uso | Símbulo |
| :-: | :-: | :-: | :-: |
| Compactada | Ocupa o mínimo de espaço possível | Interno | **!** |
| Não compactada | Feita para ser o mais legível possível | Interno | **#** |
| Convencional | Segue o "padrão *LUA*" para bibliotecas | Externo | **@** |

# Onde o Tic80 busca *bibliotecas externas*
Ao contrário do que possa aparentar, o Tic80 não busca por bibliotecas na pasta onde seus cartuchos são armazenados (`..\com.nesbox.tic\TIC-80`), mas sim no diretório onde está seu executável, dentro de uma pasta chamada `lua` (que  Tic80 não cria sozinho/quando instalado).

* ###### [Fonte](https://github.com/nesbox/TIC-80/wiki/Using-require-to-load-external-code-into-your-cart)

![toStoreLibraries](https://github.com/duckafire/TinyLibrary/assets/155199080/5219f3af-9a5c-4b04-a0c4-2c75611f3b21)
![usingRequire](https://github.com/duckafire/TinyLibrary/assets/155199080/cb8fb07b-0cba-477c-be35-a536cfb8a846)

* ###### Conteúdo da biblioteca acima: `return "No functions here..."`

# Como ativar/usar as bibliotecas
Como dito anteriormente, esta coleção de bibliotecas conta com três variantes para cada biblioteca, das quais, duas são *internas* e uma *externas*. Essa classificação implica em onde e como elas devem ser posicionadas para poderem ser usadas.
| Classif. | Como usar |
| :-: | :-- |
| Interna | Copie e cole o código da biblioteca dentro do cartucho, preferencialmente no topo dele. Pode não funcionar corretamente se a biblioteca em questão não for estruturada para ser usada desta maneira. |
| Externa | Deve ser colocada na pasta `lua`, como especificado em **Onde o Tic80 busca *bibliotecas externas***, e então, exigida no código com a função especifica da linguagem (`require` em *LUA*). |

### NOTA:
Acredito que bibliotecas *externas* não funcionem em cartuchos enviados para o [site do Tic80](https://tic80.com), já que não há como enviar seus respectivos arquivos junto ao cartucho (`.tic`).
Ao exportar um cartucho (em `.exe` por exemplo) que tenha uma biblioteca *externa*, é necessário manter uma pasta, nomeada como `lua`, no mesmo diretório que ele, pois assim como o Tic80, os executáveis também buscam bibliotecas neste *local*
Desculpe por todo e qualquer erro ortografico

---
