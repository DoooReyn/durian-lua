-- 添加lua搜索路径
package.path = "src/?.lua;src/framework/protobuf/?.lua"

-- 区别于quick的全局
local GG = {}
_G.GG = GG

-- 魔法系列
GG.Magic = require("magic")
_G.__G__TRACKBACK__ = GG.Magic.CatchLuaError

-- 控制台
GG.Console = GG.Magic.ReadOnlyTable(require("console"))
GG.Console.init()

-- 环境配置
GG.Env = GG.Magic.ReadOnlyTable(require("env"))

-- 数据检查器
GG.Checker = GG.Magic.ReadOnlyTable(require("checker"))

-- 定长数值数组
GG.Vec = require("vec")
local v1 = GG.Vec(1)
local v2 = GG.Vec(1)
local v3 = GG.Vec(1,2,3,false)
local v4 = GG.Vec(1,2,3,true)
local t1 = v1:equal(v2)
local t2 = v3 == v4
print(v1:str(), v2:str(), v3:str(), v4:str(), t1, t2)

-- 程序入口
-- require("app.MyApp").new():run()