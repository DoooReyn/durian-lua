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

-- 程序入口
-- require("app.MyApp").new():run()