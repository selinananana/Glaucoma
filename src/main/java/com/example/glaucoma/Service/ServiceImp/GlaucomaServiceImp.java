package com.example.glaucoma.Service.ServiceImp;

import com.example.glaucoma.Service.GlaucomaService;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class GlaucomaServiceImp implements GlaucomaService {

    @Override
    public boolean HandelReauest(String filename) throws IOException, InterruptedException {
        //调用CAB
        Process pr;
        pr = Runtime.getRuntime().exec("G:\\Anaconda\\envs\\CABnet\\python.exe G:\\PyCharm_Project\\CABnet\\test.py");
        int exitCode = pr.waitFor();

        if (exitCode == 0) {
            // 进程正常退出，输出进程结果
            InputStream inputStream = pr.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
                // 将 Python 脚本的输出内容存储到变量中，以便后续处理
            }
        } else {
            // 进程异常退出，获取错误输出流
            InputStream errorStream = pr.getErrorStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(errorStream));
            String line;
            while ((line = reader.readLine()) != null) {
                System.err.println(line);
            }
        }
        System.out.println(pr.waitFor());

        return false;
    }
}
