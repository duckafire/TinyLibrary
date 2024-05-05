#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(){
	char keyword[22][9] = {
		"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if",
		"in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while",
	};

	FILE *file, *new;
	
	file = fopen("temp.txt", "r");
	new  = fopen("new_text.txt", "w");

	if(file == NULL){
		printf("[tin] File not founded.");
		exit(1);
	}
	
	char cc, word[25];
	int add;

	while((cc = fgetc(file) != EOF)){
		// it have not a graphic representation
		if((cc < 33 || cc == 127) && cc != '\t') continue;

		// if find a number and inital character of "word" in null
		if(cc >= 48 && cc <= 57 && word[0] == '\0'){
			fputc(cc, new);
			continue;
		}

		// check spaces and special characters
		if(cc == ' ' || (cc != '_' && !(cc >= 48 && cc <= 57) && !(cc >= 64 && cc <= 90) && !(cc >= 97 && cc <= 122))){
			
			// check language sintaxe
			add = 0;
			for(int i = 0; i < 22; i++){
				if(strcmp(word, keyword[i]) == 0){
					add = 1;
					break;
				}
			}
			
			if(add){
				fprintf(new, "%s", word);
			}else{
				fputc(word[0], new);
			}

			memset(word, '\0', 25);
			continue;
		}

		// update current word
		word[strlen(word)] = cc;

	}

	fclose(file);
	fclose(new);
	return 0;
}
