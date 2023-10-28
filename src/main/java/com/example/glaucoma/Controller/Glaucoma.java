package com.example.glaucoma.Controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import org.python.util.PythonInterpreter;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

@RestController
public class Glaucoma {
    @RequestMapping("/judge")

    public ResponseEntity<String> judge(@RequestParam("file") MultipartFile multipartFile) throws IOException, InterruptedException {
        try {
            System.out.println("进入后台!");
            // 保存文件到本地
            String filePath = "C:\\Users\\lx\\Desktop\\Glaucoma\\IdeaProject\\Glaucoma\\image\\upload"; // 替换为你希望保存文件的路径
            String originalFilename = multipartFile.getOriginalFilename();
            String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String filename="1";
//            String newFilename = System.currentTimeMillis() + fileExtension;  //使用文件原名称进行保存
            String newFilename = filename + fileExtension;
            File file = new File(filePath, newFilename);
            multipartFile.transferTo(file);
        } catch (IOException e) {
            e.printStackTrace();
            // 处理文件保存异常
            //return "保存文件失败";
        }

        //调用模型


        //矫正
        Process prmap;
        prmap = Runtime.getRuntime().exec("C:\\\\Users\\\\lx\\\\anaconda3\\\\envs\\\\Glaucoma\\\\python.exe ././././model/map.py");
        int mapexitCode = prmap.waitFor();
        if (mapexitCode == 0) {
            // 进程正常退出，输出进程结果
            InputStream inputStream = prmap.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
            String line;

            while ((line = reader.readLine()) != null) {
                System.out.println("矫正成功");
                System.out.println(line);
                // 将 Python 脚本的输出内容存储到变量中，以便后续处理
            }
        } else {
            // 进程异常退出，获取错误输出流
            InputStream errorStream = prmap.getErrorStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(errorStream));
            String line;
            while ((line = reader.readLine()) != null) {
                System.err.println("矫正失败");
                System.err.println(line);
            }
        }



        //去噪

        System.out.println("去噪");
        try {
            Process process = Runtime.getRuntime().exec("python ././././model/deb.py");

            int exitCode = process.waitFor();

            if (exitCode == 0) {
                // 进程正常退出，输出进程结果
                InputStream inputStream = process.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                String line;
                System.out.println("去噪成功");
                while ((line = reader.readLine()) != null) {
                    System.out.println(line);
                    // 将 Python 脚本的输出内容存储到变量中，以便后续处理
                }
            } else {
                // 进程异常退出，获取错误输出流
                InputStream errorStream = process.getErrorStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(errorStream));
                String line;
                while ((line = reader.readLine()) != null) {
                    System.err.println("去噪失败");
                    System.err.println(line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        //识别
        Process pr;
        pr = Runtime.getRuntime().exec("C:\\\\Users\\\\lx\\\\anaconda3\\\\envs\\\\Glaucoma\\\\python.exe ././././model/main.py");
        int exitCode = pr.waitFor();
        String ans=null;
//        Process pr;
//        pr = Runtime.getRuntime().exec("G:\\Anaconda\\envs\\CABnet\\python.exe G:\\test.py");
//        int exitCode = pr.waitFor();
        if (exitCode == 0) {
            // 进程正常退出，输出进程结果
            InputStream inputStream = pr.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println("输出为："+line);
                ans=line;
            }
            // 将 Python 脚本的输出内容存储到变量中，以便后续处理
            System.out.println("测评结果为："+ans);
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
        //给前台返回三张照片
        System.out.println("ans:"+ans);

        String path1="././././image/map/1.jpg";
        String path2="././././image/deblur/1.jpg";
        //String path3=ans;
        List pathlist=new ArrayList();
        pathlist.add(path1);
        pathlist.add(path2);

        ArrayList<String> picture = new ArrayList<>();
        try {
            for(Object imgPath:pathlist){
                FileInputStream fileInputStream = new FileInputStream((String) imgPath);
                byte[] imageData = new byte[fileInputStream.available()];
                fileInputStream.read(imageData);
                fileInputStream.close();
                String base64Image = Base64.getEncoder().encodeToString(imageData);
                picture.add("data:image/jpg;base64,"+base64Image);
            }
            picture.add(ans);
        }catch (Exception e) {
            e.printStackTrace();
            picture.add("picture get false!");
        }
        String jsonResponse;
        try {
            jsonResponse = new ObjectMapper().writeValueAsString(picture);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
        System.out.println("后台完工");
        return ResponseEntity.ok(jsonResponse);
    }
}
