
package imgtomap;

import javax.swing.SwingUtilities;

/**
 *
 * @author maik
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                JFrameMain frame = new JFrameMain();
                frame.setVisible(true);
            }
        });
        
    }

}
