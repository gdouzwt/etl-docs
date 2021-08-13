业务跟踪这个模块数据显示为联动，按月、年维度，接着查看这 9 个小卡片的内容，下方 *占比分析* 和 数据明细会联动，每次都调用3 条 API，对应的 SQL 语句如下：

![预警汇总-月](/etl-docs/img/warn.gif)

### 预警汇总

> 按月、年分别给出了 SQL，其中返回结果包含了 ‘套数’(count) 和 ‘金额’(amount)
> ![](/etl-docs/img/Snipaste_2021-08-13_10-02-59.png)

```sql

-- 认购未签约-月
SELECT '认购未签约' name, IFNULL(sum(1), 0) count, IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vmp.project_name
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND DATE_FORMAT(t.subscribingDate, '%Y-%m') = '2021-07';

-- 认购未签约-年
SELECT '认购未签约' name, IFNULL(sum(1), 0) count, IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vmp.project_name
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND DATE_FORMAT(t.subscribingDate, '%Y') = '2021';
```



---

![](/etl-docs/img/Snipaste_2021-08-13_10-05-53.png)
![](/etl-docs/img/Snipaste_2021-08-13_10-06-46.png)

```sql
-- 逾期未签约-月
SELECT '逾期未签约' name, IFNULL(sum(1), 0) count, IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m-%d') < DATE_FORMAT(NOW(), '%Y-%m-%d')
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m') = '2021-07';

-- 逾期未签约-年
SELECT '逾期未签约' name, IFNULL(sum(1), 0) count, IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m-%d') < DATE_FORMAT(NOW(), '%Y-%m-%d')
  AND DATE_FORMAT(t.ExpiryDate, '%Y') = '2021';
```

---

![](/etl-docs/img/Snipaste_2021-08-13_10-09-42.png)
![](/etl-docs/img/Snipaste_2021-08-13_10-10-28.png)

```sql
-- 签约未收款-月
SELECT '签约未收款' name, IFNULL(SUM(cm.roomNum), 0) AS count, IFNULL(SUM(cm.noReceiveAmount), 0) AS amount
FROM jsczb_month_contractnoreceivemoney cm
         JOIN bijsc_producttype bp ON bp.productTypetId = cm.productTypeId
WHERE cm.reportMonth = '2021-07'
  AND cm.reportDate = DATE_FORMAT('2021-07', '%Y-%m-%d');
  
-- 签约未收款-年
SELECT '签约未收款' name, IFNULL(SUM(cm.roomNum), 0) AS count, IFNULL(SUM(cm.noReceiveAmount), 0) AS amount
FROM jsczb_month_contractnoreceivemoney cm
         JOIN bijsc_producttype bp ON bp.productTypetId = cm.productTypeId
WHERE LEFT(cm.reportMonth, 4) = '2021'
  AND cm.reportDate = DATE_FORMAT('2021-07', '%Y-%m-%d');
```

---

![](/etl-docs/img/Snipaste_2021-08-13_10-11-19.png)
![](/etl-docs/img/Snipaste_2021-08-13_10-11-47.png)

```sql
-- 逾期未收款-月
SELECT '逾期未收款' name, IFNULL(sum(1), 0) count, IFNULL(sum(t.weishouMoney), 0) amount
FROM bijsc_contractreceivmoney t
WHERE t.isDeleted = 0
  AND t.contractIsClosed = 0
  AND t.contractIsDeleted = 0
  AND t.weishouMoney > 0
  AND t.fundName != '定金'
  AND DATE_FORMAT(t.yingshouDate, '%Y-%m-d%') < DATE_FORMAT(NOW(), '%Y-%m-d%')
  AND date_format(t.yingshouDate, '%Y-%m') = '2021-07';
  
-- 逾期未收款-年
SELECT '逾期未收款' name, IFNULL(sum(1), 0) count, IFNULL(sum(t.weishouMoney), 0) amount
FROM bijsc_contractreceivmoney t
WHERE t.isDeleted = 0
  AND t.contractIsClosed = 0
  AND t.contractIsDeleted = 0
  AND t.weishouMoney > 0
  AND t.fundName != '定金'
  AND DATE_FORMAT(t.yingshouDate, '%Y-%m-d%') < DATE_FORMAT('2021-07', '%Y-%m-d%');
```

---

![](/etl-docs/img/Snipaste_2021-08-13_10-12-19.png)
![](/etl-docs/img/Snipaste_2021-08-13_10-12-42.png)

```sql
-- 退认购-月
SELECT '退认购'                                                    name,
       IFNULL(sum(mc.CancelRoomNum), 0)                         count,
       IFNULL(sum(mc.CancelRoomAmount), 0)                      amount,
       IFNULL(sum(mc.CancelRoomAmount) / sum(mc.RoomAmount), 0) rate
FROM jsczb_month_cancelsubscribing AS mc
         JOIN bijsc_producttype bp ON bp.productTypetId = mc.productTypeID
WHERE mc.reportMonth = '2021-07'
  AND mc.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d');
-- 退认购-年
SELECT '退认购'                                                    name,
       IFNULL(sum(yc.CancelRoomNum), 0)                         count,
       IFNULL(sum(yc.CancelRoomAmount), 0)                      amount,
       IFNULL(sum(yc.CancelRoomAmount) / sum(yc.RoomAmount), 0) rate
FROM jsczb_year_cancelsubscribing AS yc
         JOIN bijsc_producttype bp ON bp.productTypetId = yc.productTypeID
WHERE yc.reportYear = '2021'
  AND yc.reportDate = DATE_FORMAT('2021-07', '%Y-%m-%d');
```

---

![](/etl-docs/img/Snipaste_2021-08-13_10-13-15.png)
![](/etl-docs/img/Snipaste_2021-08-13_10-13-34.png)

```sql
-- 退签约-月
SELECT '退签约'                                                                                    name,
       sum(CASE WHEN c.isclosed = 1 AND ce.change_type = '退 房' THEN 1 ELSE 0 END)               count,
       sum(CASE WHEN c.isclosed = 1 AND ce.change_type = '退房' THEN c.contractAmount ELSE 0 END) amount
FROM bijsc_contractdetail c
         JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         LEFT JOIN bijsc_change_execute ce ON c.contractguid = ce.datakey
WHERE c.isDeleted = 0
  AND DATE_FORMAT(ce.executed_time, '%Y-%m') = '2021-07'
  AND ce.change_type = '退房';
  
-- 退签约-年
SELECT '退签约' name,
    sum(
        CASE
            WHEN c.isclosed = 1
            AND ce.change_type = '退房' THEN 1
            ELSE 0
        END
    ) count,
    sum(
        CASE
            WHEN c.isclosed = 1
            AND ce.change_type = '退房' THEN c.contractAmount
            ELSE 0
        END
    ) amount
FROM bijsc_contractdetail c
    JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
    JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
    LEFT JOIN bijsc_change_execute ce ON c.contractguid = ce.datakey
WHERE c.isDeleted = 0
    AND DATE_FORMAT(ce.executed_time, '%Y') = '2021'
    AND ce.change_type = '退房';
```

---

![](/etl-docs/img/Snipaste_2021-08-13_10-14-59.png)

![](/etl-docs/img/Snipaste_2021-08-13_10-14-11.png)


```sql
-- 签约首付回款-月
SELECT '签约首付回款'                                                  name,
       IFNULL(sum(crf.RoomNum), 0)                               count,
       IFNULL(sum(crf.firstAmount), 0)                           amount,
       IFNULL(sum(crf.firstAmount) / sum(crf.contractAmount), 0) rate
FROM jsczb_month_contractreceivefirst AS crf
         JOIN bijsc_producttype bp ON bp.productTypetId = crf.productTypeId
WHERE crf.reportMonth = '2021-07'
  AND crf.reportDate = DATE_FORMAT('2021-07', '%Y-%m-%d');
  
-- 签约首付回款-年
SELECT '签约首付回款'                                                  name,
       IFNULL(sum(crf.RoomNum), 0)                               count,
       IFNULL(sum(crf.firstAmount), 0)                           amount,
       IFNULL(sum(crf.firstAmount) / sum(crf.contractAmount), 0) rate
FROM jsczb_year_contractreceivefirst AS crf
         JOIN bijsc_producttype bp ON bp.productTypetId = crf.productTypeId
WHERE crf.reportYear = '2021'
  AND crf.reportDate = DATE_FORMAT('2021', '%Y-%m-%d');
```

![](/etl-docs/img/Snipaste_2021-08-13_10-16-31.png)
![](/etl-docs/img/Snipaste_2021-08-13_10-17-56.png)

```sql
-- 破底-月
SELECT '破底'                                                                                           name,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END) / sum(1)                      rate,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END)                               count,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN r.floorprice - c.contractAmount ELSE 0 END) amount
FROM bijsc_contractdetail c
         LEFT JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE c.isclosed = 0
  AND c.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND c.contractDate >= '2021-07';
  
-- 破底-年
SELECT '破底'                                                                                           name,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END) / sum(1)                      rate,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END)                               count,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN r.floorprice - c.contractAmount ELSE 0 END) amount
FROM bijsc_contractdetail c
         LEFT JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE c.isclosed = 0
  AND c.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND c.contractDate >= '2021';
```

---

![](/etl-docs/img/Snipaste_2021-08-13_10-18-39.png)
![](/etl-docs/img/Snipaste_2021-08-13_10-19-23.png)

```sql
-- 滞销存货比-月
SELECT '滞销存货比'                                            name,
       IFNULL(sum(mh.12month_roomCount), 0)               count,
       IFNULL(sum(mh.12month_cunhuo), 0)                  amount,
       IFNULL(sum(mh.12month_cunhuo) / sum(mh.cunhuo), 0) rate
FROM jsczb_month_huozhipct AS mh
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE mh.reportMonth = '2021-07'
  AND mh.reportDate = DATE_FORMAT('2021-07', '%Y-%m-%d');

-- 滞销存货比-年
SELECT '滞销存货比'                                            name,
       IFNULL(sum(mh.12month_roomCount), 0)               count,
       IFNULL(sum(mh.12month_cunhuo), 0)                  amount,
       IFNULL(sum(mh.12month_cunhuo) / sum(mh.cunhuo), 0) rate
FROM jsczb_month_huozhipct AS mh
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE LEFT(mh.reportMonth, 4) = '2021'
  AND mh.reportDate = DATE_FORMAT('2021', '%Y-%m-%d');
```

### 占比分析

![](/etl-docs/img/Snipaste_2021-08-13_09-59-22.png)

```sql
-- 认购未签约-月
SELECT ma.pk_area code, ma.areaname name, IFNULL(sum(1), 0) count, IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vmp.project_name
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND DATE_FORMAT(t.subscribingDate, '%Y-%m') = '2021-07'
GROUP BY ma.pk_area, ma.areaname
ORDER BY amount DESC;
```

上面执行结果是：

```
+------+--------------------+-------+-------------+
| code | name               | count | amount      |
+------+--------------------+-------+-------------+
| 1503 | 成渝事业部         |     2 | 38499707.00 |
| 1101 | 南一区域公司       |    11 | 33765590.00 |
| 1102 | 南二区域公司       |    24 | 22375676.00 |
| 1401 | 北一区域公司       |    15 | 16582667.00 |
| 1301 | 东一区域公司       |    10 | 16434378.00 |
| 1501 | 西一区域公司       |    28 | 13455835.00 |
| 1402 | 太原事业部         |     6 |  4917431.00 |
| 1106 | 株洲事业部         |     5 |  3108539.00 |
| 1403 | 北三区域公司       |     2 |  3058931.00 |
| 1201 | 中一区域公司       |     4 |  2426948.00 |
| 1404 | 北四区域公司       |     3 |  1666164.00 |
| 1502 | 西二区域公司       |     2 |  1315777.00 |
+------+--------------------+-------+-------------+
```

然后前端计算出占比，按年维度查询也类似，不再重复这部分说明。

##### 认购未签约-数据明细

![](/etl-docs/img/Snipaste_2021-08-13_10-21-01.png)

```sql
-- 数据明细-月
-- 获取区域代码-后面重复部分不再写
SELECT pk_area areacode, areaname
FROM v_md_area
WHERE parentid IS NOT NULL
  AND dr = 0
ORDER BY sort;
-- 获取项目的金额
SELECT ma.pk_area                       areacode,
       t.projectId                      pid,
       t.projectName                    name,
       IFNULL(sum(1), 0)                count,
       IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vmp.project_name
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND DATE_FORMAT(t.subscribingDate, '%Y-%m') = '2021-07'  -- 参数
GROUP BY t.projectId, t.projectName
ORDER BY amount DESC;
-- 认购未签约-月-数据明细 - part 1
SELECT '认购未签约' name, IFNULL(sum(1), 0) count, IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vmp.project_name
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND DATE_FORMAT(t.subscribingDate, '%Y-%m') = '2021-07';  -- 参数
  
-- part 2
SELECT vmp.project_name     projectName,
       vmp.project_code     projectCode,
       vmp.id_project       idProject,
       vmp.belong_area      belongArea,
       vmp.belong_provinces belongProvinces,
       vmp.belong_city      belongCity,
       vma.areaname         areaName
FROM v_md_projectinfo vmp
         LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN
      ('P0001', 'P0002', 'P0003', 'P0004', 'P0005', 'P0006', 'P0007', 'P0009', 'P0010', 'P0011', 'P0012', 'P0018', 'P0019', 'P0026', 'P0046', 'P0048', 'P0062', 'P0063', 'P0064', 'P0065', 'P0067', 'P0071', 'P0076', 'P0084', 'P0085', 'P0086', 'P0087', 'P0089', 'P0090', 'P0091', 'P0093', 'P0094', 'P0095', 'P0096', 'P0097', 'P0098', 'P0099', 'P0100',
       'P0106', 'P0109', 'P0110', 'P0111', 'P0112', 'P0113', 'P0117', 'P0118', 'P0120', 'P0123', 'P0124');
```

结果(part 1)：

```
+-----------------+-------+--------------+
| name            | count | amount       |
+-----------------+-------+--------------+
| 认购未签约      |   120 | 203900029.00  |
+-----------------+-------+--------------+
```


```sql
-- 认购未签约-年-占比分析
SELECT ma.pk_area code, ma.areaname name, IFNULL(sum(1), 0) count, IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vmp.project_name
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND DATE_FORMAT(t.subscribingDate, '%Y') = '2021'
GROUP BY ma.pk_area, ma.areaname
ORDER BY amount DESC;
-- 认购未签约-年-占比分析-数据明细
SELECT '认购未签约' name, IFNULL(sum(1), 0) count, IFNULL(sum(t.protocolAmount), 0) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vmp.project_name
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND DATE_FORMAT(t.subscribingDate, '%Y') = '2021';
-- part 2
SELECT vmp.project_name     projectName,
       vmp.project_code     projectCode,
       vmp.id_project       idProject,
       vmp.belong_area      belongArea,
       vmp.belong_provinces belongProvinces,
       vmp.belong_city      belongCity,
       vma.areaname         areaName
FROM v_md_projectinfo vmp
         LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN
      ('P0001', 'P0002', 'P0003', 'P0004', 'P0005', 'P0006', 'P0007', 'P0009', 'P0010', 'P0011', 'P0012', 'P0018', 'P0019', 'P0026', 'P0046', 'P0048', 'P0062', 'P0063', 'P0064', 'P0065', 'P0067', 'P0071', 'P0076', 'P0084', 'P0085', 'P0086', 'P0087', 'P0089', 'P0090', 'P0091', 'P0093', 'P0094', 'P0095', 'P0096', 'P0097', 'P0098', 'P0099', 'P0100',
       'P0106', 'P0109', 'P0110', 'P0111', 'P0112', 'P0113', 'P0117', 'P0118', 'P0120', 'P0123', 'P0124');
```

---

##### 逾期未签约

![](/etl-docs/img/Snipaste_2021-08-13_10-30-54.png)

```sql
-- 逾期未签约-月
SELECT ma.areaname name, ma.pk_area code, sum(1) count, sum(t.protocolAmount) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vma.areacode
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
         JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m-%d') < DATE_FORMAT('2021-07', '%Y-%m-%d')
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m') = '2021-07'
GROUP BY ma.pk_area, ma.areaname;

-- 逾期未签约-年
SELECT ma.areaname name, ma.pk_area code, sum(1) count, sum(t.protocolAmount) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vma.areacode
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m-%d') < DATE_FORMAT('2021', '%Y-%m-%d')
  AND DATE_FORMAT(t.ExpiryDate, '%Y') = '2021'
GROUP BY ma.pk_area, ma.areaname;

-- 数据明细
-- 先获得 区域代码同上
-- part 1
SELECT mp.belong_area areacode, t.projectId pid, t.projectName name, sum(1) count, sum(t.protocolAmount) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         JOIN v_md_projectinfo mp ON t.projectId = mp.id_project
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m-%d') < DATE_FORMAT('2021-07', '%Y-%m-%d')
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m') = '2021-07'
GROUP BY t.projectId, t.projectName;
-- part 2
SELECT vmp.project_name     projectName,
       vmp.project_code     projectCode,
       vmp.id_project       idProject,
       vmp.belong_area      belongArea,
       vmp.belong_provinces belongProvinces,
       vmp.belong_city      belongCity,
       vma.areaname         areaName
FROM v_md_projectinfo vmp
         LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN
      ('P0001', 'P0002', 'P0003', 'P0004', 'P0005', 'P0006', 'P0007', 'P0009', 'P0010', 'P0011', 'P0012', 'P0018', 'P0019', 'P0026', 'P0046', 'P0048', 'P0062', 'P0063', 'P0064', 'P0065', 'P0067', 'P0071', 'P0076', 'P0084', 'P0085', 'P0086', 'P0087', 'P0089', 'P0090', 'P0091', 'P0093', 'P0094', 'P0095', 'P0096', 'P0097', 'P0098', 'P0099', 'P0100',
       'P0106', 'P0109', 'P0110', 'P0111', 'P0112', 'P0113', 'P0117', 'P0118', 'P0120', 'P0123', 'P0124');
       
-- 如果是项目维度，得到业态
-- part 1
SELECT t.projectId           areacode,
       mp.belong_area        pid,
       pt.productTypeName    name,
       pt.productTypetId     tid,
       sum(1)                count,
       sum(t.protocolAmount) amount
FROM bijsc_subscribingdetail t
         JOIN bijsc_onsalesroom r ON t.roomid = r.roomid
         JOIN v_md_projectinfo mp ON t.projectId = mp.id_project
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE t.isClosed = 0
  AND t.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m-%d') < DATE_FORMAT(NOW(), '%Y-%m-%d')
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m') = '2021-07'
GROUP BY t.projectId, t.projectName, pt.productTypetId;

```

---

注意：👋 **下面其它项都是类同的操作，不再重复多遍了，只需替换参数即可。**

##### 签约未收款

![](/etl-docs/img/Snipaste_2021-08-13_10-32-15.png)

```sql
-- 签约未收款-月
SELECT vmp.belong_area                    AS code,
       vma.areaname                       AS `name`,
       IFNULL(SUM(cm.roomNum), 0)         AS count,
       IFNULL(SUM(cm.noReceiveAmount), 0) AS amount
FROM `v_md_projectinfo` AS vmp
         JOIN v_md_area AS vma ON vma.pk_area = vmp.belong_area
         JOIN jsczb_month_contractnoreceivemoney cm ON cm.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = cm.productTypeId
WHERE cm.reportMonth = '2021-07'
  AND cm.reportDate = DATE_FORMAT('2021-07', '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;

-- 签约未收款-年
SELECT vmp.belong_area                    AS code,
       vma.areaname                       AS `name`,
       IFNULL(SUM(cm.roomNum), 0)         AS count,
       IFNULL(SUM(cm.noReceiveAmount), 0) AS amount
FROM `v_md_projectinfo` AS vmp
         JOIN v_md_area AS vma ON vma.pk_area = vmp.belong_area
         JOIN jsczb_month_contractnoreceivemoney cm ON cm.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = cm.productTypeId
WHERE LEFT(cm.reportMonth, 4) = '2021'
  AND cm.reportDate = DATE_FORMAT('2021', '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;
```

##### 逾期未收款

![](/etl-docs/img/Snipaste_2021-08-13_10-34-25.png)

```sql
-- 逾期未收款-月
SELECT ma.areaname name, ma.pk_area code, sum(1) count, sum(t.weishouMoney) amount
FROM bijsc_contractreceivmoney t
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vma.areacode
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isDeleted = 0
  AND t.contractIsClosed = 0
  AND t.contractIsDeleted = 0
  AND t.weishouMoney > 0
  AND t.fundName != '定金'
  AND DATE_FORMAT(t.yingshouDate, '%Y-%m-d%') < DATE_FORMAT('2021-07', '%Y-%m-d%')
  AND DATE_FORMAT(t.yingshouDate, '%Y-%m') = '2021-07'
GROUP BY ma.pk_area, ma.areaname;

-- 逾期未收款-年
SELECT ma.areaname name, ma.pk_area code, sum(1) count, sum(t.weishouMoney) amount
FROM bijsc_contractreceivmoney t
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vma.areacode
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = t.projectId
WHERE t.isDeleted = 0
  AND t.contractIsClosed = 0
  AND t.contractIsDeleted = 0
  AND t.weishouMoney > 0
  AND t.fundName != '定金'
  AND DATE_FORMAT(t.yingshouDate, '%Y-%m-d%') < DATE_FORMAT('2021', '%Y-%m-d%')
GROUP BY ma.pk_area, ma.areaname;
```

##### 退认购

![](/etl-docs/img/Snipaste_2021-08-13_10-33-11.png)

```sql
-- 退认购-月
SELECT vmp.belong_area AS                  code,
       vma.areaname    AS                  `name`,
       IFNULL(sum(mc.CancelRoomNum), 0)    count,
       IFNULL(sum(mc.CancelRoomAmount), 0) amount
FROM `v_md_projectinfo` AS vmp
         JOIN v_md_area AS vma ON vma.pk_area = vmp.belong_area
         JOIN jsczb_month_cancelsubscribing AS mc ON mc.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = mc.productTypeID
WHERE mc.reportMonth = '2021-07'
  AND mc.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;

-- 退认购-年
SELECT vmp.belong_area AS                  code,
       vma.areaname    AS                  `name`,
       IFNULL(sum(mc.CancelRoomNum), 0)    count,
       IFNULL(sum(mc.CancelRoomAmount), 0) amount
FROM `v_md_projectinfo` AS vmp
         JOIN v_md_area AS vma ON vma.pk_area = vmp.belong_area
         JOIN jsczb_year_cancelsubscribing AS mc ON mc.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = mc.productTypeId
WHERE mc.reportYear = '2021'
  AND mc.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;
```

##### 退签约

![](/etl-docs/img/Snipaste_2021-08-13_10-35-00.png)

```sql
-- 退签约-月
SELECT ma.areaname                                                                                 name,
       ma.pk_area                                                                                  code,
       sum(CASE WHEN c.IsClosed = 0 OR c.isclosed = 1 AND ce.change_type = '退房' THEN 1 ELSE 0 END) qianyue_num,
       sum(CASE WHEN c.isclosed = 1 AND ce.change_type = '退房' THEN 1 ELSE 0 END)                   count,
       sum(CASE WHEN c.isclosed = 1 AND ce.change_type = '退房' THEN c.contractAmount ELSE 0 END)    amount
FROM bijsc_contractdetail c
         JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vma.areacode
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = c.projectId
         JOIN bijsc_change_execute ce ON c.contractguid = ce.datakey
WHERE c.isDeleted = 0
  AND ce.change_type = '退房'
  AND DATE_FORMAT(ce.executed_time, '%Y-%m') = '2021-07'
GROUP BY ma.pk_area, ma.areaname;

-- 退签约-年
SELECT ma.areaname                                                                                 name,
       ma.pk_area                                                                                  code,
       sum(CASE WHEN c.IsClosed = 0 OR c.isclosed = 1 AND ce.change_type = '退房' THEN 1 ELSE 0 END) qianyue_num,
       sum(CASE WHEN c.isclosed = 1 AND ce.change_type = '退房' THEN 1 ELSE 0 END)                   count,
       sum(CASE WHEN c.isclosed = 1 AND ce.change_type = '退房' THEN c.contractAmount ELSE 0 END)    amount
FROM bijsc_contractdetail c
         JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vma.areacode
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = c.projectId
         JOIN bijsc_change_execute ce ON c.contractguid = ce.datakey
WHERE c.isDeleted = 0
  AND ce.change_type = '退房'
  AND DATE_FORMAT(ce.executed_time, '%Y') = '2021'
GROUP BY ma.pk_area, ma.areaname;
```

##### 签约首付回款

![](/etl-docs/img/Snipaste_2021-08-13_10-35-41.png)

```sql
-- 签约首付回款-月
SELECT vmp.belong_area AS              code,
       vma.areaname    AS              `name`,
       IFNULL(sum(crf.RoomNum), 0)     count,
       IFNULL(sum(crf.firstAmount), 0) amount
FROM `v_md_projectinfo` AS vmp
         JOIN v_md_area AS vma ON vma.pk_area = vmp.belong_area
         JOIN jsczb_month_contractreceivefirst AS crf ON crf.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = crf.productTypeId
WHERE crf.reportMonth = '2021-07'
  AND crf.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;

-- 签约首付回款-年
SELECT vmp.belong_area AS              code,
       vma.areaname    AS              `name`,
       IFNULL(sum(crf.RoomNum), 0)     count,
       IFNULL(sum(crf.firstAmount), 0) amount
FROM `v_md_projectinfo` AS vmp
         JOIN v_md_area AS vma ON vma.pk_area = vmp.belong_area
         JOIN jsczb_year_contractreceivefirst AS crf ON crf.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = crf.productTypeId
WHERE crf.reportYear = '2021'
  AND crf.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;
```

##### 破底

![](/etl-docs/img/Snipaste_2021-08-13_10-36-39.png)

```sql
-- 破底-月
SELECT ma.areaname                                                      name,
       ma.areacode                                                      code,
       sum(1)                                                           qianyue_num,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END) count,
       sum(r.floorprice - c.contractAmount)                             amount
FROM bijsc_contractdetail c
         LEFT JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vma.areacode
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = c.projectId
WHERE c.isclosed = 0
  AND c.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND c.contractAmount < r.floorprice
  AND c.contractDate <= '2021-07'
GROUP BY ma.pk_area, ma.areaname;

-- 破底-年
SELECT ma.areaname                                                      name,
       ma.pk_area                                                       code,
       sum(1)                                                           qianyue_num,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END) count,
       sum(r.floorprice - c.contractAmount)                             amount
FROM bijsc_contractdetail c
         LEFT JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
         JOIN (SELECT vma.pk_area, vmp.id_project, vma.areaname, vma.areacode
               FROM v_md_projectinfo vmp
                        JOIN v_md_area vma ON vmp.belong_area = vma.pk_area) ma ON ma.id_project = c.projectId
WHERE c.isclosed = 0
  AND c.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND c.contractAmount < r.floorprice
  AND c.contractDate <= '2021'
GROUP BY ma.pk_area, ma.areaname;
-- 破底-区域-数据明细-月
SELECT mp.belong_area                                                   areacode,
       c.projectId                                                      pid,
       c.projectName                                                    name,
       sum(1)                                                           qianyue_num,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END) count,
       sum(r.floorprice - c.contractAmount)                             amount
FROM bijsc_contractdetail c
         JOIN v_md_projectinfo mp ON mp.id_project = c.projectId
         LEFT JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE c.isclosed = 0
  AND c.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND c.contractAmount < r.floorprice
  AND DATE_FORMAT(c.contractDate, '%Y-%m') = '2021-07'
GROUP BY c.projectId, c.projectName;
-- 破底-区域-数据明细-年
SELECT mp.belong_area                                                   areacode,
       c.projectId                                                      pid,
       c.projectName                                                    name,
       sum(1)                                                           qianyue_num,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END) count,
       sum(r.floorprice - c.contractAmount)                             amount
FROM bijsc_contractdetail c
         JOIN v_md_projectinfo mp ON mp.id_project = c.projectId
         LEFT JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE c.isclosed = 0
  AND c.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND c.contractAmount < r.floorprice
  AND DATE_FORMAT(c.contractDate, '%Y') = '2021'
GROUP BY c.projectId, c.projectName;
-- 破底-项目-数据明细-月
SELECT c.projectId                                                      areacode,
       mp.belong_area                                                   pid,
       pt.productTypeName                                               name,
       pt.productTypetId                                                tid,
       sum(1)                                                           qianyue_num,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END) count,
       sum(r.floorprice - c.contractAmount)                             amount
FROM bijsc_contractdetail c
         JOIN v_md_projectinfo mp ON mp.id_project = c.projectId
         LEFT JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE c.isclosed = 0
  AND c.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND c.contractAmount < r.floorprice
  AND DATE_FORMAT(c.contractDate, '%Y-%m') = '2021-07'
GROUP BY c.projectId, c.projectName, pt.productTypetId;

-- 破底-项目-数据明细-年
SELECT c.projectId                                                      areacode,
       mp.belong_area                                                   pid,
       pt.productTypeName                                               name,
       pt.productTypetId                                                tid,
       sum(1)                                                           qianyue_num,
       sum(CASE WHEN c.contractAmount < r.floorprice THEN 1 ELSE 0 END) count,
       sum(r.floorprice - c.contractAmount)                             amount
FROM bijsc_contractdetail c
         JOIN v_md_projectinfo mp ON mp.id_project = c.projectId
         LEFT JOIN bijsc_onsalesroom r ON c.roomid = r.roomid
         LEFT JOIN bijsc_producttype pt ON r.productType = pt.productTypetId
WHERE c.isclosed = 0
  AND c.isDeleted = 0
  AND pt.productTypeName NOT LIKE '%车%'
  AND c.contractAmount < r.floorprice
  AND DATE_FORMAT(c.contractDate, '%Y') = '2021'
GROUP BY c.projectId, c.projectName, pt.productTypetId;
```

##### 滞销存货比

![](/etl-docs/img/Snipaste_2021-08-13_10-37-36.png)

```sql
-- 滞销存货比-月
SELECT vmp.belong_area AS                   code,
       vma.areaname    AS                   `name`,
       IFNULL(sum(mh.12month_roomCount), 0) count,
       IFNULL(sum(mh.12month_cunhuo), 0)    amount
FROM `v_md_projectinfo` AS vmp
         JOIN v_md_area as vma ON vma.pk_area = vmp.belong_area
         JOIN jsczb_month_huozhipct AS mh ON mh.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE mh.reportMonth = '2021-07'
  AND mh.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;

-- 滞销存货比-年
SELECT vmp.belong_area AS                   code,
       vma.areaname    AS                   `name`,
       IFNULL(sum(mh.12month_roomCount), 0) count,
       IFNULL(sum(mh.12month_cunhuo), 0)    amount
FROM `v_md_projectinfo` AS vmp
         JOIN v_md_area as vma ON vma.pk_area = vmp.belong_area
         JOIN jsczb_month_huozhipct AS mh ON mh.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE LEFT(mh.reportMonth, 4) = '2021'
  AND mh.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;

-- 数据明细-区域-月
-- 先拿到区域代码和名称，下面不重复这部分了
SELECT pk_area areacode, areaname FROM v_md_area WHERE parentid IS NOT NULL AND dr = 0 ORDER BY sort;
-- 当月数据
SELECT vmp.belong_area                                    areacode,
       mh.projectId                                       pid,
       vmp.project_name                                   name,
       IFNULL(sum(mh.cunhuo), 0)         AS               count,
       IFNULL(sum(mh.12month_cunhuo), 0) AS               amount,
       IFNULL(sum(mh.12month_cunhuo) / sum(mh.cunhuo), 0) amountRate
FROM `v_md_projectinfo` AS vmp
         JOIN jsczb_month_huozhipct AS mh ON mh.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE mh.reportMonth = '2021-07'
  AND mh.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY mh.projectId
ORDER BY amountRate;
-- 项目代号
SELECT vmp.project_name     projectName,
       vmp.project_code     projectCode,
       vmp.id_project       idProject,
       vmp.belong_area      belongArea,
       vmp.belong_provinces belongProvinces,
       vmp.belong_city      belongCity,
       vma.areaname         areaName
FROM v_md_projectinfo vmp
         LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN
      (P0001, P0002, P0003, P0004, P0005, P0006, P0007, P0009, P0010, P0011, P0012, P0018, P0019, P0026, P0046, P0048, P0062, P0063, P0064, P0065, P0067, P0071, P0076, P0084, P0085, P0086, P0087, P0089, P0090, P0091, P0093, P0094, P0095, P0096, P0097, P0098, P0099, P0100,
       P0106, P0109, P0110, P0111, P0112, P0113, P0117, P0118, P0120, P0123, P0124);
-- 组织架构？
SELECT t.md_area_code FROM md_area_uc_code t WHERE t.is_enabled = 1 AND t.uc_code IN ('10001');

-- 数据明细-区域-年
SELECT vmp.belong_area                                    areacode,
       mh.projectId                                       pid,
       vmp.project_name                                   name,
       IFNULL(sum(mh.cunhuo), 0)         AS               count,
       IFNULL(sum(mh.12month_cunhuo), 0) AS               amount,
       IFNULL(sum(mh.12month_cunhuo) / sum(mh.cunhuo), 0) amountRate
FROM `v_md_projectinfo` AS vmp
         JOIN jsczb_month_huozhipct AS mh ON mh.projectId = vmp.id_project
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE LEFT(mh.reportMonth, 4) = '2021'
  AND mh.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY mh.projectId
ORDER BY amountRate;
-- 其它同上

-- 数据明细-项目-月
-- 得到项目名和项目id，注意这里仍别名为 areaname 和 areacode，是为了代码处理方便
SELECT project_name AS areaname, id_project AS areacode
FROM v_md_projectinfo
ORDER BY id_project;
-- 取二级菜单数据
SELECT mh.projectId                                       areacode,
       bp.productTypeName                                 name,
       IFNULL(sum(mh.cunhuo), 0)         AS               count,
       IFNULL(sum(mh.12month_cunhuo), 0) AS               amount,
       IFNULL(sum(mh.12month_cunhuo) / sum(mh.cunhuo), 0) amountRate
FROM jsczb_month_huozhipct AS mh
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE mh.reportMonth = '2021-07'
  AND mh.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY mh.projectId, bp.productTypetId
ORDER BY amountRate;
-- 找到所属关系
SELECT vmp.project_name     projectName,
       vmp.project_code     projectCode,
       vmp.id_project       idProject,
       vmp.belong_area      belongArea,
       vmp.belong_provinces belongProvinces,
       vmp.belong_city      belongCity,
       vma.areaname         areaName
FROM v_md_projectinfo vmp
         LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN
      ('P0001', 'P0002', 'P0003', 'P0004', 'P0005', 'P0006', 'P0007', 'P0009', 'P0010', 'P0011', 'P0012', 'P0018', 'P0019', 'P0026', 'P0046', 'P0048', 'P0062', 'P0063', 'P0064', 'P0065', 'P0067', 'P0071', 'P0076', 'P0084', 'P0085', 'P0086', 'P0087', 'P0089', 'P0090', 'P0091', 'P0093', 'P0094', 'P0095', 'P0096', 'P0097', 'P0098', 'P0099', 'P0100',
       'P0106', 'P0109', 'P0110', 'P0111', 'P0112', 'P0113', 'P0117', 'P0118', 'P0120', 'P0123', 'P0124');

-- 数据明细-项目-年
-- 其它类似，核心是详细数据
SELECT mh.projectId                                       areacode,
       bp.productTypeName                                 name,
       IFNULL(sum(mh.cunhuo), 0)         AS               count,
       IFNULL(sum(mh.12month_cunhuo), 0) AS               amount,
       IFNULL(sum(mh.12month_cunhuo) / sum(mh.cunhuo), 0) amountRate
FROM jsczb_month_huozhipct AS mh
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE LEFT(mh.reportMonth, 4) = '2021'
  AND mh.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY mh.projectId, bp.productTypetId
ORDER BY amountRate;
```

### 数据明细

> 见占比分析里面 SQL

【完】
