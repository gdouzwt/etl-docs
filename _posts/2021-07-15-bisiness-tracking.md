---
layout: post
title:  "业务跟踪"
date:   2021-07-15 14:28:52 
---

业务跟踪这个模块数据显示为联动，按月、年维度，接着查看这 9 个小卡片的内容，下方 *占比分析* 和 数据明细会联动，每次都调用3 条 API，对应的 SQL 语句如下：

![预警汇总-月](/etl-docs/img/warn.gif)

### 预警汇总

> 按月、年分别给出了 SQL，其中返回结果包含了 ‘套数’(count) 和 ‘金额’(amount)

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

```sql
-- 签约未收款-月
SELECT '签约未收款' name, IFNULL(SUM(cm.roomNum), 0) AS count, IFNULL(SUM(cm.noReceiveAmount), 0) AS amount
FROM jsczb_month_contractnoreceivemoney cm
         JOIN bijsc_producttype bp ON bp.productTypetId = cm.productTypeId
WHERE cm.reportMonth = '2021-07'
  AND cm.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d');
  
-- 签约未收款-年
SELECT '签约未收款' name, IFNULL(SUM(cm.roomNum), 0) AS count, IFNULL(SUM(cm.noReceiveAmount), 0) AS amount
FROM jsczb_month_contractnoreceivemoney cm
         JOIN bijsc_producttype bp ON bp.productTypetId = cm.productTypeId
WHERE LEFT(cm.reportMonth, 4) = '2021'
  AND cm.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d');
```

---

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
  AND DATE_FORMAT(t.yingshouDate, '%Y-%m-d%') < DATE_FORMAT(NOW(), '%Y-%m-d%');
```

---

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
  AND yc.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d');
```

---

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

```sql
-- 签约首付回款-月
SELECT '签约首付回款'                                                  name,
       IFNULL(sum(crf.RoomNum), 0)                               count,
       IFNULL(sum(crf.firstAmount), 0)                           amount,
       IFNULL(sum(crf.firstAmount) / sum(crf.contractAmount), 0) rate
FROM jsczb_month_contractreceivefirst AS crf
         JOIN bijsc_producttype bp ON bp.productTypetId = crf.productTypeId
WHERE crf.reportMonth = '2021-07'
  AND crf.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d');
  
-- 签约首付回款-年
SELECT '签约首付回款'                                                  name,
       IFNULL(sum(crf.RoomNum), 0)                               count,
       IFNULL(sum(crf.firstAmount), 0)                           amount,
       IFNULL(sum(crf.firstAmount) / sum(crf.contractAmount), 0) rate
FROM jsczb_year_contractreceivefirst AS crf
         JOIN bijsc_producttype bp ON bp.productTypetId = crf.productTypeId
WHERE crf.reportYear = '2021'
  AND crf.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d');
```

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

```sql
-- 滞销存货比-月
SELECT '滞销存货比'                                            name,
       IFNULL(sum(mh.12month_roomCount), 0)               count,
       IFNULL(sum(mh.12month_cunhuo), 0)                  amount,
       IFNULL(sum(mh.12month_cunhuo) / sum(mh.cunhuo), 0) rate
FROM jsczb_month_huozhipct AS mh
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE mh.reportMonth = '2021-07'
  AND mh.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d');

-- 滞销存货比-年
SELECT '滞销存货比'                                            name,
       IFNULL(sum(mh.12month_roomCount), 0)               count,
       IFNULL(sum(mh.12month_cunhuo), 0)                  amount,
       IFNULL(sum(mh.12month_cunhuo) / sum(mh.cunhuo), 0) rate
FROM jsczb_month_huozhipct AS mh
         JOIN bijsc_producttype bp ON bp.productTypetId = mh.productTypeId
WHERE LEFT(mh.reportMonth, 4) = '2021'
  AND mh.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d');
```

### 占比分析

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

```sql
-- 认购未签约-年
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
```

##### 逾期未签约

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
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m-%d') < DATE_FORMAT(NOW(), '%Y-%m-%d')
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
  AND DATE_FORMAT(t.ExpiryDate, '%Y-%m-%d') < DATE_FORMAT(NOW(), '%Y-%m-%d')
  AND DATE_FORMAT(t.ExpiryDate, '%Y') = '2021'
GROUP BY ma.pk_area, ma.areaname;
```

##### 签约未收款

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
  AND cm.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
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
  AND cm.reportDate = DATE_FORMAT(CURRENT_DATE(), '%Y-%m-%d')
GROUP BY vma.areacode, vma.areaname;
```

##### 逾期未收款

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
  AND DATE_FORMAT(t.yingshouDate, '%Y-%m-d%') < DATE_FORMAT(NOW(), '%Y-%m-d%')
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
  AND DATE_FORMAT(t.yingshouDate, '%Y-%m-d%') < DATE_FORMAT(NOW(), '%Y-%m-d%')
GROUP BY ma.pk_area, ma.areaname;
```

##### 退认购

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
  AND c.contractDate >= '2021-07'
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
  AND c.contractDate >= '2021'
GROUP BY ma.pk_area, ma.areaname;
```

##### 滞销存货比

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
```



### 数据明细
