/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package imgtomap;

import java.awt.image.BufferedImage;
import java.awt.image.Raster;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;

/**
 *
 * @author maik
 */
public class MapWriter {

    public int writeMap(Parameters p) {
        if (!(new File(p.infile).exists())) {
            return 1;
        }

        FileOutputStream fos;
        try {
            fos = new FileOutputStream(new File(p.outfile));
        } catch (FileNotFoundException ex) {
            Logger.getLogger(MapWriter.class.getName()).log(Level.SEVERE, null, ex);
            return 1;
        }

        double[][] height = getHeightmap(p.infile);
        double units = 1d * p.pixelsize;
        double max = p.height;

        PrintWriter pw = null;
        try {
            pw = new PrintWriter(new FileOutputStream(new File(p.outfile)));
        } catch (FileNotFoundException ex) {
            Logger.getLogger(MapWriter.class.getName()).log(Level.SEVERE, null, ex);
            return 1;
        }
        

        // worldspawn start
        pw.print("{\n\"classname\" \"worldspawn\"\n");

        // wander through grid
        for (int x = 0; x < height.length - 1; ++x) {
            for (int y = 0; y < height[0].length - 1; ++y) {

                boolean skip = height[x][y] < 0 || height[x][y + 1] < 0 || height[x + 1][y] < 0 || height[x + 1][y + 1] < 0;

                if (!skip) {

                    /*
                     * 
                     *      a +-------+ b
                     *       /       /|
                     *      /       / |
                     *     /       /  |
                     *  c +-------+ d + f   (e occluded, unused)
                     *    |       |  /
                     *    |       | /
                     *    |       |/
                     *  g +-------+ h
                     * 
                     */

                    Vector3D a = new Vector3D(x * units, -y * units, height[x][y] * max);
                    Vector3D b = new Vector3D((x + 1) * units, -y * units, height[x + 1][y] * max);
                    Vector3D c = new Vector3D(x * units, -(y + 1) * units, height[x][y + 1] * max);
                    Vector3D d = new Vector3D((x + 1) * units, -(y + 1) * units, height[x + 1][y + 1] * max);
                    //Vector3D e = new Vector3D(x * units, -y * units, -16.0);
                    Vector3D f = new Vector3D((x + 1) * units, -y * units, -16.0);
                    Vector3D g = new Vector3D(x * units, -(y + 1) * units, -16.0);
                    Vector3D h = new Vector3D((x + 1) * units, -(y + 1) * units, -16.0);

                    pw.print("{\n");
                    pw.print(getMapPlaneString(a, b, d, p.detail, p.texture, p.texturescale));
                    pw.print(getMapPlaneString(d, b, f, p.detail, "common/caulk", p.texturescale));
                    pw.print(getMapPlaneString(f, b, a, p.detail, "common/caulk", p.texturescale));
                    pw.print(getMapPlaneString(a, d, h, p.detail, "common/caulk", p.texturescale));
                    pw.print(getMapPlaneString(g, h, f, p.detail, "common/caulk", p.texturescale));
                    pw.print("}\n");


                    pw.print("{\n");
                    pw.print(getMapPlaneString(d, c, a, p.detail, p.texture, p.texturescale));
                    pw.print(getMapPlaneString(g, c, d, p.detail, "common/caulk", p.texturescale));
                    pw.print(getMapPlaneString(c, g, a, p.detail, "common/caulk", p.texturescale));
                    pw.print(getMapPlaneString(h, d, a, p.detail, "common/caulk", p.texturescale));
                    pw.print(getMapPlaneString(g, h, f, p.detail, "common/caulk", p.texturescale));
                    pw.print("}\n");
                } else if (p.skyfill) {

                    boolean totalskip = height[x][y] < -5 || height[x][y + 1] < -5 || height[x + 1][y] < -5 || height[x + 1][y + 1] < -5;

                    if (!totalskip) {
                        // fill skipped blocks with sky
                        Vector3D p1 = new Vector3D(x * units, -(y + 1) * units, -32.0);
                        Vector3D p2 = new Vector3D((x + 1) * units, -y * units, p.skyheight);

                        writeBoxBrush(pw, p1, p2, false, p.skytexture, 1.0);
                    }
                }
            }
        }

        if (p.sky) {
            // generate skybox
            int x = height.length - 1;
            int y = height[0].length - 1;

            // top
            Vector3D p1 = new Vector3D(0, -y * units, p.skyheight);
            Vector3D p2 = new Vector3D(x * units, 0, p.skyheight + 32.0);
            writeBoxBrush(pw, p1, p2, false, p.skytexture, 1.0);

            // bottom
            p1 = new Vector3D(0, -y * units, -64.0);
            p2 = new Vector3D(x * units, 0, -32.0);
            writeBoxBrush(pw, p1, p2, false, p.skytexture, 1.0);

            // north
            p1 = new Vector3D(0, 0, -32.0);
            p2 = new Vector3D(x * units, 32, p.skyheight);
            writeBoxBrush(pw, p1, p2, false, p.skytexture, 1.0);

            // east
            p1 = new Vector3D(x * units, -y * units, -32.0);
            p2 = new Vector3D(x * units + 32.0, 0, p.skyheight);
            writeBoxBrush(pw, p1, p2, false, p.skytexture, 1.0);

            // south
            p1 = new Vector3D(0, -y * units - 32, -32.0);
            p2 = new Vector3D(x * units, -y * units, p.skyheight);
            writeBoxBrush(pw, p1, p2, false, p.skytexture, 1.0);


            // west
            p1 = new Vector3D(0 - 32.0, -y * units, -32.0);
            p2 = new Vector3D(0, 0, p.skyheight);
            writeBoxBrush(pw, p1, p2, false, p.skytexture, 1.0);

        }

        // worldspawn end
        pw.print("}\n");
        pw.close();
        return 0;
    }

    private void writeBoxBrush(PrintWriter pw, Vector3D p1, Vector3D p2, boolean detail, String texture, double scale) {
        Vector3D a = new Vector3D(p1.x, p2.y, p2.z);
        Vector3D b = p2;
        Vector3D c = new Vector3D(p1.x, p1.y, p2.z);
        Vector3D d = new Vector3D(p2.x, p1.y, p2.z);
        //Vector3D e unused
        Vector3D f = new Vector3D(p2.x, p2.y, p1.z);
        Vector3D g = p1;
        Vector3D h = new Vector3D(p2.x, p1.y, p1.z);

        pw.print("{\n");
        pw.print(getMapPlaneString(a, b, d, detail, texture, scale));
        pw.print(getMapPlaneString(d, b, f, detail, texture, scale));
        pw.print(getMapPlaneString(c, d, h, detail, texture, scale));
        pw.print(getMapPlaneString(a, c, g, detail, texture, scale));
        pw.print(getMapPlaneString(f, b, a, detail, texture, scale));
        pw.print(getMapPlaneString(g, h, f, detail, texture, scale));
        pw.print("}\n");

    }

    private String getMapPlaneString(Vector3D p1, Vector3D p2, Vector3D p3, boolean detail, String material, double scale) {
        int flag;
        if (detail) {
            flag = 134217728;
        } else {
            flag = 0;
        }
        return "( " + p1.x + " " + p1.y + " " + p1.z + " ) ( " + p2.x + " " + p2.y + " " + p2.z + " ) ( " + p3.x + " " + p3.y + " " + p3.z + " ) " + material + " 0 0 0 " + scale + " " + scale + " " + flag + " 0 0\n";
    }

    private class Vector3D {

        public double x,  y,  z;

        public Vector3D() {
            this(0.0, 0.0, 0.0);
        }

        public Vector3D(double x, double y, double z) {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public Vector3D crossproduct(Vector3D p1) {
            Vector3D result = new Vector3D();

            result.x = this.y * p1.z - this.z * p1.y;
            result.y = this.z * p1.x - this.x * p1.z;
            result.z = this.x * p1.y - this.y * p1.x;

            return result;
        }

        public double dotproduct(Vector3D p1) {
            return this.x * p1.x + this.y * p1.y + this.z * p1.z;
        }

        public Vector3D substract(Vector3D p1) {
            Vector3D result = new Vector3D();

            result.x = this.x - p1.x;
            result.y = this.y - p1.y;
            result.z = this.z - p1.z;

            return result;
        }

        public void scale(double factor) {
            x *= factor;
            y *= factor;
            z *= factor;
        }

        public double length() {
            return Math.sqrt((x * x) + (y * y) + (z * z));
        }

        public void normalize() {
            double l = length();

            x /= l;
            y /= l;
            z /= l;
        }
    }

    private double[][] markTotalSkip(double[][] input) {
        double[][] result = new double[input.length][input[0].length];

        int xmax = input.length - 1;
        int ymax = input[0].length - 1;

        for (int x = 0; x <= xmax; ++x) {
            for (int y = 0; y <= ymax; ++y) {
                double val;
                double max;

                val = input[x][y];
                max = val;

                if (x - 1 >= 0 && y - 1 >= 0) {
                    val = input[x - 1][y - 1];
                    max = val > max ? val : max;
                }

                if (y - 1 >= 0) {
                    val = input[x][y - 1];
                    max = val > max ? val : max;
                }

                if (x + 1 <= xmax && y - 1 >= 0) {
                    val = input[x + 1][y - 1];
                    max = val > max ? val : max;
                }

                if (x - 1 >= 0) {
                    val = input[x - 1][y];
                    max = val > max ? val : max;
                }

                if (x + 1 <= xmax) {
                    val = input[x + 1][y];
                    max = val > max ? val : max;
                }

                if (x - 1 >= 0 && y + 1 <= ymax) {
                    val = input[x - 1][y + 1];
                    max = val > max ? val : max;
                }

                if (y + 1 <= ymax) {
                    val = input[x][y + 1];
                    max = val > max ? val : max;
                }

                if (x + 1 <= xmax && y + 1 <= ymax) {
                    val = input[x + 1][y + 1];
                    max = val > max ? val : max;
                }

                if (max < 0) {
                    result[x][y] = -10.0;
                } else {
                    result[x][y] = input[x][y];
                }

            }
        }


        return result;
    }

    private double[][] getHeightmap(String file) {
        try {
            BufferedImage bimg = ImageIO.read(new File(file));
            Raster raster = bimg.getRaster();
            int x = raster.getWidth();
            int y = raster.getHeight();

            double[][] result = new double[x][y];

            for (int xi = 0; xi < x; ++xi) {
                for (int yi = 0; yi < y; ++yi) {
                    float[] pixel = raster.getPixel(xi, yi, (float[]) null);

                    int channels;
                    boolean alpha;
                    if (pixel.length == 3) {
                        // RGB
                        channels = 3;
                        alpha = false;
                    } else if (pixel.length == 4) {
                        // RGBA
                        channels = 3;
                        alpha = true;
                    } else if (pixel.length == 1) {
                        // grayscale
                        channels = 1;
                        alpha = false;
                    } else {
                        // grayscale with alpha
                        channels = 1;
                        alpha = true;
                    }

                    float tmp = 0f;
                    for (int i = 0; i < channels; ++i) {
                        tmp += pixel[i];
                    }
                    result[xi][yi] = tmp / (channels * 255f);

                    if (alpha) {
                        // mark this pixel to be skipped
                        if (pixel[pixel.length - 1] < 64.0) {
                            result[xi][yi] = -1.0;
                        }
                    }
                }
            }


            return markTotalSkip(result);
        } catch (IOException ex) {
            Logger.getLogger(MapWriter.class.getName()).log(Level.SEVERE, null, ex);
        }

        return null;
    }
}
