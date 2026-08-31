# Vigatamala 拦截规则

[繁體中文](/rules.zh-Hant) · [简体中文](/rules.zh-Hans) · [English](/rules.en) · [日本語](/rules.ja) · [한국어](/rules.ko)

这里存放 Vigatamala iOS 浏览器使用的广告与跟踪器拦截规则。

这两份列表**不随 App 打包**,而是由用户在 App 内下载 ——
也就是说,下面这些文件就是 App 实际会取用的那一份转换产物,
任何人也都可以直接下载、查看或自行使用(见下方许可)。

## 下载

| 文件 | 说明 |
|---|---|
| [easylist.json](https://privacy.link2us.link/rules/easylist.json) | EasyList 的 content blocker 改编版 |
| [easylist.NOTICE.txt](https://privacy.link2us.link/rules/easylist.NOTICE.txt) | 署名与上游版权声明 |
| [easyprivacy.json](https://privacy.link2us.link/rules/easyprivacy.json) | EasyPrivacy 的 content blocker 改编版 |
| [easyprivacy.NOTICE.txt](https://privacy.link2us.link/rules/easyprivacy.NOTICE.txt) | 同上 |
| [easylist.json.sig](https://privacy.link2us.link/rules/easylist.json.sig) | Ed25519 签名(App 端验证用) |
| [easyprivacy.json.sig](https://privacy.link2us.link/rules/easyprivacy.json.sig) | 同上 |

## 这是什么

上面两份 JSON 是 [EasyList](https://easylist.to/) 与 EasyPrivacy 的**改编作品**:
我们把 Adblock Plus 过滤语法转换成 Apple 的 Safari content blocker JSON 格式,
过程中:

- 舍弃了该格式无法表达的规则类型(scriptlet 注入、高级选项等);
- 截断至 65,000 条 —— 这是**我们自己选的**保守上限(顾及旧机型的编译时间与
  内存),不是格式的极限。以今天的上游来说这个上限**没有真的砍到东西**
  (easylist 60,928 条、easyprivacy 55,895 条,都在上限之内)。
  WebKit 当前会在解析阶段拒收超过 150,000 条的列表,但那个数字是 WebKit 的
  实现细节(Apple 文档并未写明,2020 年底才从 50,000 调高),而且是对着
  “编译进程约 150 MB 的内存预算”定出来的上界 —— 能编得起来的条数与
  值得编的条数不是同一件事,我们不打算靠近那条线。

因此它**不等于**上游列表,拦截效果也不完全相同。
想要完整原版请直接用[上游来源](https://easylist.to/)。

## 许可

上游以 GPLv3 或 CC BY-SA 3.0 Unported 双许可发布,由用户择一。
**本改编版明示采用 CC BY-SA 3.0 Unported。**

- 署名:The EasyList authors (https://easylist.to/)
- 许可协议全文:<https://creativecommons.org/licenses/by-sa/3.0/legalcode>
- 原作者**不**为本改编版本背书。

每份规则旁的 `.NOTICE.txt` 逐字保留了上游文件头的版权声明
(Title / Version / Last modified / Commit / Homepage / Licence),
因为 content blocker JSON 是裸的顶层数组、没有注释语法,写不回文件内。
那些 NOTICE 也记录了每次转换所依据的上游版本与 commit,可以逐版审计。

**许可范围仅限 `rules/` 目录**;本站其余内容(隐私政策等)版权保留。

## 完整性验证

规则文件以 Ed25519 签名(`.sig` 为 base64 的 64-byte raw 签名),
Vigatamala App 内嵌对应公钥,镜像来源必须验签通过才会被采用。

## 怎么复现

`rules/converter/` 是可独立构建的转换器(与 App 内用的是同一份源代码,
同一份输入产出字节相同的输出):

```bash
cd rules/converter
swift build -c release
.build/release/RuleConverter <输入.txt> <输出.json> 65000
```

本 repo 的规则由 GitHub Actions 每日自动同步(见 `.github/workflows/`),
用的正是这份转换器。
