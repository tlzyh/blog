title: XCode使用SDL2
date: 2016-01-02
layout: post
comments: true
categories: Blog
toc: true 
tags: [SDL2]
keywords: SDL2

---

# 0.环境
操作系统：Mac OS X Yosemite

开发工具：Xcode6

SDL库版本：2.x


# 1.Xcode创建工程
打开XCode创建一个Cocoa Application工程。如图所示：

![创建工程](/images/sdl2_on_mac/sdltest_new_project.png)

<!--more-->

下一步到了工程配置的界面，根据你的需要填写工程的名称等信息。我这里就叫做SDLTest。配置如下如所示：

![工程配置](/images/sdl2_on_mac/sdltest_project_config.png)

下面的步骤使用默认的即可，直达工程创建完成。


# 2.删除多余项目
由于我们并不需要Xcode给我们创建的多余的文件。首先，删除多余的源文件和支持文件。如下图所示：

![删除多余源文件](/images/sdl2_on_mac/sdltest_delete_source.png)

弹出确认框，选择Move To Trash。彻底删除。这个时候还需要删除测试项目的Targets。打开Targets侧边栏，选中SDLTestTests（名称为你项目名字后面加上Tests，我的项目叫做SDLTest，所以名称为SDLTestTests）删除。如下图所示：

![删除测试工程](/images/sdl2_on_mac/sdltest_delete_test_target.png)

最后只剩下Info.plist文件，Targets只有SDLTest。


# 3.添加文件
添加工程需要的源文件和库文件。

## 3.1 添加源文件
删除到其他的东西之后，是时候添加源文件了。添加一个名字为main.cpp的源文件。添加过程如图所示：

![添加源文件](/images/sdl2_on_mac/sdltest_add_source.png)


## 3.2 添加SDL2库文件
点击工程文件，打开Targets侧边栏，选择Targets下面的SDLTest Target，在选择Build Phases选项卡，展开Link Binary With Libraries选项。如下图所示：

![添加库文件](/images/sdl2_on_mac/sdltest_add_lib1.png)

然后选择SDL2的库文件即可。其实，还有一种更为简单的方法就是，直接把库文件拖到工程中，会出现一个添加文件的配置选项框。如图所示：

![添加库文件](/images/sdl2_on_mac/sdltest_drag_lib.png)

点击Finish，完成添加。

## 3.3 添加测试代码
打开main.cpp文件添加如下的测试代码。

```
#include <SDL2/SDL.h>
int main(int argc, const char** argv)
{
    if(SDL_Init(SDL_INIT_EVERYTHING) != 0)
    {
        puts("SDL_Init error");
        return -1;
    }
    else
    {
        puts("SDL_Init success!");
        return 0;
    }
}
```

直接编译运行。不出意外会输出**SDL_Init success!**. 


# 4. 可能出现的问题
在最后可能出现dylib出现SDL动态库的Image没有找到。那么选择Build Phases选项卡，点击最上面的**+**号，选择**New Copy Files Phases**，添加一个**Copy Files**的分类，再把**Destination**改为**Framesworks**，再使用添加库文件的方式，添加SDL库，如图所示：

![添加Copy Files](/images/sdl2_on_mac/sdltest_copy_files.png)


