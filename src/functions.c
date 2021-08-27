unsigned char	AVIS_DURGAN_DICTIONARY[] = "Avis Durgan";

void DecryptUsingAvisDurgan(unsigned char* from, unsigned char* to) {

	unsigned char* dic = AVIS_DURGAN_DICTIONARY;

	while(from < to) {
		if(*dic == 0) dic = AVIS_DURGAN_DICTIONARY;
		*from++ ^= *dic++;
	}
}
