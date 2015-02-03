class SequenceDistribution {
    int DELIMITER = 0;
    int NSYMBOLS = 1;
    int []symbols = null;
        
    // the first of the symbols in this array is considered the "delimiter", and
    // all other symbols not appearing in the array are collapsed into it.
    public SequenceDistribution(int []a_symbols) {
        symbols = a_symbols;
        NSYMBOLS = symbols.length;
    }
    
    public SequenceDistribution(int n_symbols) {
        symbols = new int[n_symbols];
        for(int i = 0;i<n_symbols;i++) symbols[i] = i;
        NSYMBOLS = symbols.length;
    }
    
    
    public int symbolIndex(int symbol) {
        for(int i = 0;i<NSYMBOLS;i++) {
            if (symbols[i]==symbol) return i;
        }
        return DELIMITER;
    }
        
    public ArrayList<Integer> generateSequence(int maxLength) {
        return generateSequence(maxLength,false);
    }        
    
    public ArrayList<Integer> generateSequence(int maxLength, boolean delimitByDelimiters)
    {
        return null;
    }
}
