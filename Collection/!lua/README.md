# Does the Tic80 have support for external libraries?
If you have ever tried to access a library file in Tic80, using, for example, "require" (in LUA),
you must have received a huge error and thought that Tic80 does not support the use of external
libraries, but that is not the case.

Tic80 has this support, but it does not create or specify the location where libraries should be placed.

# How to use external libraries in Tic80

To be able to use external libraries on the Tic80, you need to access the location where your executable is
stored and then create a folder called "lua". This is where Tic80 looks for the libraries required in the
code and, consequently, where you should place them, even if they are not from the LUA language.

![lua-folder](https://github.com/duckafire/TinyLibrary/assets/155199080/5219f3af-9a5c-4b04-a0c4-2c75611f3b21)

![using-require](https://github.com/duckafire/TinyLibrary/assets/155199080/cb8fb07b-0cba-477c-be35-a536cfb8a846)

* #### [Font](https://github.com/nesbox/TIC-80/wiki/Using-require-to-load-external-code-into-your-cart "Tic80 Oficial Wiki: How to use require")

# Important:
It is important to remember that the use of external libraries is not possible for cartridges sent to the Tic80 website,
as there is no way to send extra files, so it ends up being better to use "internal libraries".

Exported cartridges (in ".exe" for example) look for the libraries required by their code in the same way as the Tic80,
that is, if you export a cartridge, you will need to maintain a folder called "lua" (containing the libraries that the
cartridge uses) in your directory.

















* ###### [Fonte](https://github.com/nesbox/TIC-80/wiki/Using-require-to-load-external-code-into-your-cart "Tic80 Wiki")

![folder-lua](https://github.com/duckafire/TinyLibrary/assets/155199080/5219f3af-9a5c-4b04-a0c4-2c75611f3b21)
![using-require-on-tic80](https://github.com/duckafire/TinyLibrary/assets/155199080/cb8fb07b-0cba-477c-be35-a536cfb8a846)