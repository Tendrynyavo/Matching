package connection;

public class Sequence extends BddObject {
    
    String sequence;

    public void setSequence(String sequence) {
        this.sequence = sequence;
    }

    public String getSequence() {
        return sequence;
    }

    public static Sequence[] convert(Object[] objects) {
        Sequence[] sequences = new Sequence[objects.length];
        for (int i = 0; i < sequences.length; i++)
            sequences[i] = (Sequence) objects[i];
        return sequences;
    }
}
