title: Http表单文件上传
date: 2016-01-03 00:10:00
layout: post
comments: true
categories: Blog
toc: true 
tags: [文件上传]
keywords: 文件上传, Servlet

---
# 0. 介绍
在开发的过程中不免会使用的文件上传的功能。实习的时候第一次见到工程代码里面有使用Http的方式来上传用户图片的代码，感觉好复杂，各种字段不明其意。下面就使用表单加上Servlet的方式看看文件如何上传。

# 1. 创建一个文件上传表单
这东西也是大二的时候学的，现在已经忘记的差不多了。代码如下：

```
<html>
	<head>
		<title>File Uploading Form</title>
	</head>
	<body>
		<h3>File Upload:</h3> Select a file to upload: <br />
		<form action="UploadServlet" method="post" enctype="multipart/form-data">
		<input type="file" name="file" size="50" />
		<br />
		<input type="submit" value="Upload File" />
		</form>
	</body>
</html>
```
上面部分有下面几点必须注意：

* **method** 必须为 **post**
* **enctype** 设置为 **multipart/form-data**
* **action** 要和你的Servlet文件名称一致

<!--more-->

# 2. 后端Servlet处理
Servlet要做的事情就是相应文件上传的事件。由于使用的是**Post**方式，所以，在Servlet代码中需要重写**doPost**方法。代码如下所示：
```
import java.io.File;
import java.util.List;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class UploadServlet extends HttpServlet {
	static final String SAVE_DIR = "E:/Test/Upload/";
	static final int BUFFER_SIZE = 4096;
	protected void doPost(HttpServletRequest request,
		HttpServletResponse response) throws ServletException, IOException{

		String fileName = "request.bin";
		File saveFile = new File(SAVE_DIR + fileName);

		System.out.println("===== Begin headers =====");
		Enumeration<String> names = request.getHeaderNames();
		while (names.hasMoreElements()) {
			String headerName = names.nextElement();
			System.out.println(headerName + " = " + request.getHeader(headerName));			
		}
		System.out.println("===== End headers =====\n");
		// raw data
		InputStream inputStream = request.getInputStream();
		FileOutputStream outputStream = new FileOutputStream(saveFile);
		
		byte[] buffer = new byte[BUFFER_SIZE];
		int bytesRead = -1;
		System.out.println("Receiving data...");
		
		while ((bytesRead = inputStream.read(buffer)) != -1) {
			outputStream.write(buffer, 0, bytesRead);
		}
		
		System.out.println("Data received.");
		outputStream.close();
		inputStream.close();
		
		System.out.println("File written to: " + saveFile.getAbsolutePath());
		response.getWriter().print("UPLOAD DONE");
	}
}
```
获得请求之后，首先打印了请求的头部信息，然后再将**Request Body**（注意不是文件数据）的数据存储到文件中。

# 3.部署、运行
平台：Windows8.1

Http服务器：Tomcat8.0.24

## 3.1 Tomcat下创建项目
这个测试项目很简单，没有必要使用其他的工具，可以直接复制Tomcat下面的实例工程修改即可。

第一步：在**webapps**目录下建立一个名称为**upload**的文件夹。

第二步：在**upload**目录下创建**WEB-INF**目录，再在**WEB-INF**目录下创建存放class文件的目录**classes**。

第三步：将最开始的表单代码保存为**index.html**，存放到**upload**目录下。

第四步：将**ROOT/WEB-INF**目录下面的**web.xml**配置文件拷贝到**upload/WEB-INF**。

## 3.2 编译Servlet代码
Servlet代码文件只有一个，所以，直接用命令行编译即可。不过需要注意的包名（这里没有）相关问题。由于使用了Servlet，所以在编译的时候需要指定jar包。

将上面的Servlet代码保存为**UploadServlet.java**文件，放在你操作方便的地方。打开命令行窗口，输入如下命令编译：
```
javac -cp .;[Tomcat根目录]/lib/servlet-api.jar UploadServlet.java
```
编译完成之后，会在当前目录下面生成一个class文件。

## 3.3 配置Servlet
将上一步生成的class文件拷贝到**WEB-INF/classes**目录下面。再打开web.xml配置文件。添加如下配置代码：

```
<servlet>
	  <servlet-name>UploadServlet</servlet-name>
	  <servlet-class>UploadServlet</servlet-class>
  </servlet>

  <servlet-mapping>
	  <servlet-name>UploadServlet</servlet-name>
	  <url-pattern>/UploadServlet</url-pattern>
  </servlet-mapping>
```

## 3.4 运行
打开Tomcat目录下的bin目录，双击运行**startup.bat**脚本，查看控制台是否有错误信息。运行了服务器之后，就可以用浏览器来访问了。在浏览器中输入如下地址：

```
http://localhost:8080/upload/
```
如果你修改了端口，请改成你自己的端口号。这时就有一个简单的提交文件的界面出现，如下图所示：
![表单](/images/http_upload_file/upload_form.png)
这时就可以通过这个界面上传文件了。

# 4.Request Body
如果你上传了文件，你会发现文件数据有问题，并不是那个文件的数据。对，上面的servlet保存的是Request Body的所有数据。因此，它不仅仅包含了文件数据，还包含了分割符，**Content-type**，**content-disposition**等等信息。这个具体信息请参见[RFC1867](http://www.ietf.org/rfc/rfc1867.txt) 的第6节的实例。

先来看看，上传一个1byte的文本文件上传之后的数据。使用二进制工具打开，如下图所示：
<!---->
![上传文件](/images/http_upload_file/upload_1_byte_request_body.png)
这里主要关注回车和换行。可以看到和RFC中的实例都是可以对应上的。

# 5. 提取文件
在Servlet基本的方法中并没有一个很好的方法来获取文件的数据，不过Apache提供了另外一个开源库来做这件事情。库的名称是：**commons-fileupload**。到目前为止版本号为**1.3.1**。需要注意的是这个库依赖**commons-io**这个库。两个库都可以到官方网站上下载。最后，修改代码如下：

```
import java.io.File;
import java.util.List;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.FileUploadException;

public class UploadServlet extends HttpServlet {
	static final String SAVE_DIR = "E:/Test/Upload/";
	static final int BUFFER_SIZE = 4096;
	
	protected void doPost(HttpServletRequest request,
		HttpServletResponse response) throws ServletException, IOException{

		String fileName = "request.bin";
		File saveFile = new File(SAVE_DIR + fileName);

		System.out.println("===== Begin headers =====");
		Enumeration<String> names = request.getHeaderNames();
		while (names.hasMoreElements()) {
			String headerName = names.nextElement();
			System.out.println(headerName + " = " + request.getHeader(headerName));			
		}
		System.out.println("===== End headers =====\n");

		try
		{
			request.setCharacterEncoding("UTF-8");
			DiskFileItemFactory factory = new DiskFileItemFactory();
			ServletFileUpload sfu = new ServletFileUpload(factory);
			List<FileItem> fileItems = sfu.parseRequest(request);
			for(int i = 0;i < fileItems.size(); i++){
				FileItem item = fileItems.get(i);
				if(item.isFormField()){
				}else{
					fileName = item.getName();
					String dir = SAVE_DIR;
					item.write(new File(dir + fileName));

				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return;
		}
		
		response.getWriter().print("UPLOAD DONE");
	}
}
```

重新编译，在编译的时候需要添加commons-fileupload的jar包，否则会报错。替换原来的class文件，然后把这两个jar包拷贝到Tomcat的lib目录下。再上传文件就是原来的文件了。



























