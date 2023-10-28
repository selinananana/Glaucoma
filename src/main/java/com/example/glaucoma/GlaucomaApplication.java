package com.example.glaucoma;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;


@SpringBootApplication
public class GlaucomaApplication {

    public static void main(String[] args) throws IOException, InterruptedException {
        SpringApplication.run(GlaucomaApplication.class, args);
        System.out.println("********项目启动********");


    }

}


