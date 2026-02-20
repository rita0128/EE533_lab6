// sort.c
int main() { 
    int array[10] = {323, 123, -455, 2, 98, 125, 10, 65, -56, 0};
    int i, j, swap;
    for (i = 0; i < 9; i++) {
        for (j = 0; j < 9 - i; j++) {
            if (array[j] > array[j + 1]) {
                swap = array[j];
                array[j] = array[j + 1];
                array[j + 1] = swap;
            }
        }
    }

    return 0;
}