---
layout: post
title:  "业绩看板"
date:   2021-07-12 11:19:52 +0800
---

### 指标概览

#### 指标概览-日

![](/etl-docs/img/IMG_1698.PNG)

```SQL
SELECT *
FROM (
        SELECT sum(keshou_huozhi) marketableValue  -- 可售货值
        FROM bijsc_product_huozhi
    ) hz,
    (
        SELECT IFNULL(sum(subscribingNum), 0) AS subscribingNum,  -- 认购套数
            IFNULL(sum(subscribingAmount), 0) AS subscribingAmount,  -- 认购金额
            IFNULL(sum(contractNum), 0) AS contractNum,  -- 签约套数
            IFNULL(sum(contractAmount), 0) AS contractAmount,  -- 签约金额
            IFNULL(sum(receivedMoney), 0) AS receivedMoney  -- 回款金额
        FROM jsczb_daily_report
        WHERE reportDate = '2021-07-09'
    ) dr;
```

---

#### 指标概览-周

![](/etl-docs/img/IMG_1699.PNG)

```SQL
SELECT *
FROM (
        SELECT sum(keshou_huozhi) marketableValue  -- 可售货值
        FROM bijsc_product_huozhi
    ) hz,
    (
        SELECT IFNULL(sum(subscribingNum), 0) AS subscribingNum,  -- 认购套数
            IFNULL(sum(subscribingAmount), 0) AS subscribingAmount,  -- 认购金额
            IFNULL(sum(contractNum), 0) AS contractNum,  -- 签约套数
            IFNULL(sum(contractAmount), 0) AS contractAmount,  -- 签约金额
            IFNULL(sum(receivedMoney), 0) AS receivedMoney  -- 回款金额
        FROM jsczb_daily_report
        WHERE YEARWEEK(reportDate, 1) = '202127'
    ) dr;
```

---

#### 指标概览-月

![](/etl-docs/img/IMG_1700.PNG)

```sql
SELECT aa.subscribingNum            subscribingNum,
       aa.subscribingAmount         subscribingAmount,
       aa.linbaoNum                 linbaoNum,
       aa.linbaoAmount              linbaoAmount,
       aa.vipNum                    vipNum,
       aa.vipAmount                 vipAmount,
       aa.contractNum               contractNum,
       aa.contractAmount            contractAmount,
       aa.contractAmountN           contractAmountN,
       aa.subscribingAmountN        subscribingAmountN,
       aa.contractNumN              contractNumN,
       aa.receivedMoney             receivedMoney,
       aa.receivedMoneyN            receivedMoneyN,
       aa.gonghuoAmount             gonghuoAmount,
       aa.gonghuoNum                gonghuoNum,
       aa.yingshouAmountN           yingshouAmountN,
       kk.orderIdCount              orderIdCount,
       kk.contractAmountSum,
       kk.software,
       kk.zhineng,
       kk.yingzhuang,
       kk.jiadian,
       kk.earlyReceiveAmount,
       kmk.registerNum,
       kk.receiveAmount             receiveAmount,
       jj.eCommerceNum              eCommerceAmount,
       jj.eCommerceAmount           eCommerceNum,
       ll.autoNfs                   autoNfs,
       ll.autoNpsUpdateDate         autoNpsUpdateDate,
       mm.mileage                   mileage,
       mm.operationDuration         operationDuration,
       mm.orderCount                orderCount,
       mm.proprietorTime            proprietorTime,
       mm.customerTime              customerTime,
       mm.visitorTime,
       pp.delightMileage            delightMileage,
       pp.delightOrderCount         delightOrderCount,
       pp.delightBatchCount         delightBatchCount,
       pp.delightPromoteCustomer    delightPromoteCustomer,
       pp.delightNonPromoteCustomer delightNonPromoteCustomer,
       pp.delightOrderDuration      delightOrderDuration,
       pp.delightDeliveryDuration   delightDeliveryDuration,
       nn.delightNfs                delightNfs,
       nn.delightNpsUpdateDate      delightNpsUpdateDate,
       cc.targetSubscribingAmount   targetSubscribingAmount,
       cc.targetContractAmount      targetContractAmount,
       cc.targetReceivedMoney       targetReceivedMoney,
       dd.targetGonghuoAmount       targetGonghuoAmount
FROM (SELECT reportDate,
             SUM(subscribingNum)     AS subscribingNum,
             SUM(subscribingAmount)  AS subscribingAmount,
             SUM(subscribingAmoun_n) AS subscribingAmountN,
             SUM(linbaoNum)          AS linbaoNum,
             SUM(linbaoAmount)       AS linbaoAmount,
             SUM(vipNum)             AS vipNum,
             SUM(vipAmount)          AS vipAmount,
             SUM(contractNum)        AS contractNum,
             SUM(contractAmount)     AS contractAmount,
             SUM(contractAmount_n)   AS contractAmountN,
             SUM(contractNum_n) AS contractNumN, SUM(receivedMoney) AS receivedMoney,
             SUM(receivedMoney_n)    AS receivedMoneyN,
             SUM(gonghuoAmount)      AS gonghuoAmount,
             SUM(gonghuoNum)         AS gonghuoNum,
             SUM(yingshouAmount_n)   AS yingshouAmountN
      FROM jsczb_month_report
      WHERE reportDate = DATE_FORMAT('2021-07-12', '%Y-%m-%d')) aa,
     (SELECT IFNULL(SUM(c.orderIdCount), 0)       orderIdCount,
             IFNULL(SUM(c.contractAmountSum), 0)  contractAmountSum,
             IFNULL(SUM(c.receiveAmount), 0)      receiveAmount,
             IFNULL(SUM(c.software), 0)           software,
             IFNULL(SUM(c.zhineng), 0)            zhineng,
             IFNULL(SUM(c.yingzhuang), 0)         yingzhuang,
             IFNULL(SUM(c.jiadian), 0)            jiadian,
             IFNULL(SUM(c.earlyReceiveAmount), 0) earlyReceiveAmount
      FROM (SELECT business_date          AS                             reportDate,
                   area_id                AS                             areacode,
                   COUNT(order_id)        AS                             orderIdCount,
                   SUM(contract_amount)   AS                             contractAmountSum,
                   SUM(receive_amount)    AS                             receiveAmount,
                   SUM(qq_receive_amount) AS                             earlyReceiveAmount,
                   sum(CASE WHEN product_type = '软装包' THEN 1 ELSE 0 END) software,
                   sum(CASE WHEN product_type = '智能包' THEN 1 ELSE 0 END) zhineng,
                   sum(CASE WHEN product_type = '硬装包' THEN 1 ELSE 0 END) yingzhuang,
                   sum(CASE WHEN product_type = '家电包' THEN 1 ELSE 0 END) jiadian
            FROM jsczb_linbao
            WHERE STATUS = 1
              AND LEFT(business_date, 7) = DATE_FORMAT('2021-07-12', '%Y-%m')) c) kk,
     (SELECT IFNULL(SUM(all_goods_order_cnt_not_back), 0) eCommerceAmount,
             IFNULL(SUM(all_goods_money_pay_not_back), 0) eCommerceNum
      FROM jsczb_member_order
      WHERE LEFT(create_date, 7) = DATE_FORMAT('2021-07-12', '%Y-%m')) jj,
     (SELECT nps autoNfs, nps_update_date autoNpsUpdateDate FROM jsczb_robot_auto_summary LIMIT 1) ll,
     (SELECT SUM(mileage)            mileage,
             SUM(operation_duration) operationDuration,
             SUM(order_count)        orderCount,
             SUM(proprietor_time)    proprietorTime,
             SUM(customer_time)      customerTime,
             SUM(visitor_time)       visitorTime
      FROM jsczb_robot_auto_report
      WHERE time_scale = 'month'
        AND `time` = DATE_FORMAT('2021-07-12', '%Y-%m')
        AND area_id = 0) mm,
     (SELECT SUM(mileage)                                                              delightMileage,
             SUM(order_count)                                                          delightOrderCount,
             SUM(batch_count)                                                          delightBatchCount,
             SUM(promote_customer)                                                     delightPromoteCustomer,
             SUM(non_promote_customer) delightNonPromoteCustomer,
             SUM(order_duration)                                                       delightOrderDuration,
             SUM(delivery_duration)                                                    delightDeliveryDuration
      FROM jsczb_robot_delight_report
      WHERE time_scale = 'month'
        AND `time` = DATE_FORMAT('2021-07-12', '%Y-%m')
        AND area_id = 0) pp,
     (SELECT nps delightNfs, nps_update_date delightNpsUpdateDate FROM jsczb_robot_delight_summary) nn,
     (SELECT SUM(subscribing_amount) targetSubscribingAmount,
             SUM(contract_amount)    targetContractAmount,
             SUM(received_money)     targetReceivedMoney
      FROM jsczb_target_month
      WHERE `month` = DATE_FORMAT('2021-07-12', '%Y-%m')) cc,
     (SELECT SUM(gonghuo_amount) targetGonghuoAmount
      FROM jsczb_gonghuo_target_month
      WHERE `month` = DATE_FORMAT('2021-07-12', '%Y-%m')) dd,
     (SELECT sum(reg_user_cnt) registerNum
      FROM jsczb_member_reg
      WHERE LEFT(create_date, 7) = DATE_FORMAT('2021-07-12', '%Y-%m')) kmk;
```

---

#### 指标概览-年

![](/etl-docs/img/IMG_1701.PNG)

```sql
SELECT aa.subscribingNum            subscribingNum,
       aa.subscribingAmount         subscribingAmount,
       aa.linbaoNum                 linbaoNum,
       aa.linbaoAmount              linbaoAmount,
       aa.vipNum                    vipNum,
       aa.vipAmount                 vipAmount,
       aa.contractNum               contractNum,
       aa.contractAmount            contractAmount,
       aa.contractAmountN           contractAmountN,
       aa.subscribingAmountN        subscribingAmountN,
       aa.contractNumN              contractNumN,
       aa.receivedMoney             receivedMoney,
       aa.receivedMoneyN            receivedMoneyN,
       aa.gonghuoAmount             gonghuoAmount,
       aa.gonghuoNum                gonghuoNum,
       aa.yingshouAmountN           yingshouAmountN,
       kk.orderIdCount              orderIdCount,
       kk.contractAmountSum,
       kmk.registerNum,
       kk.receiveAmount             receiveAmount,
       kk.software                  software,
       kk.zhineng                   zhineng,
       kk.yingzhuang                yingzhuang,
       kk.jiadian                   jiadian,
       kk.earlyReceiveAmount        earlyReceiveAmount,
       jj.eCommerceNum              eCommerceAmount,
       jj.eCommerceAmount           eCommerceNum,
       ll.autoNfs                   autoNfs,
       ll.autoNpsUpdateDate         autoNpsUpdateDate,
       mm.mileage                   mileage,
       mm.operationDuration         operationDuration,
       mm.orderCount                orderCount,
       mm.proprietorTime            proprietorTime,
       mm.customerTime              customerTime,
       mm.visitorTime,
       pp.delightMileage            delightMileage,
       pp.delightOrderCount         delightOrderCount,
       pp.delightBatchCount         delightBatchCount,
       pp.delightPromoteCustomer    delightPromoteCustomer,
       pp.delightNonPromoteCustomer delightNonPromoteCustomer,
       pp.delightOrderDuration      delightOrderDuration,
       pp.delightDeliveryDuration   delightDeliveryDuration,
       nn.delightNfs                delightNfs,
       nn.delightNpsUpdateDate      delightNpsUpdateDate,
       cc.targetSubscribingAmount   targetSubscribingAmount,
       cc.targetContractAmount      targetContractAmount,
       cc.targetReceivedMoney       targetReceivedMoney,
       dd.targetGonghuoAmount       targetGonghuoAmount
FROM (SELECT reportDate
           , SUM(subscribingNum)      AS subscribingNum
           , SUM(subscribingAmount)   AS subscribingAmount
           , SUM(subscribingAmount_n) AS subscribingAmountN
           , SUM(linbaoNum)           AS linbaoNum
           , SUM(linbaoAmount)        AS linbaoAmount
           , SUM(vipNum)              AS vipNum
           , SUM(vipAmount)           AS vipAmount
           , SUM(contractNum)         AS contractNum
           , SUM(contractAmount)      AS contractAmount, SUM(contractAmount_n) AS contractAmountN
           , SUM(contractNum_n)       AS contractNumN
           , SUM(receivedMoney)       AS receivedMoney
           , SUM(receivedMoney_n)     AS receivedMoneyN
           , SUM(gonghuoAmount)       AS gonghuoAmount
           , SUM(gonghuoNum)          AS gonghuoNum
           , SUM(yingshouAmount_n)    AS yingshouAmountN
      FROM jsczb_year_report
      WHERE reportDate = DATE_FORMAT('2021-07-12', '%Y-%m-%d')) aa,
     (SELECT IFNULL(SUM(c.orderIdCount), 0)       orderIdCount,
             IFNULL(SUM(c.contractAmountSum), 0)  contractAmountSum,
             IFNULL(SUM(c.receiveAmount), 0)      receiveAmount,
             IFNULL(SUM(c.software), 0)           software,
             IFNULL(SUM(c.zhineng), 0)            zhineng,
             IFNULL(SUM(c.yingzhuang), 0)         yingzhuang,
             IFNULL(SUM(c.earlyReceiveAmount), 0) earlyReceiveAmount,
             IFNULL(SUM(c.jiadian), 0)            jiadian
      FROM (SELECT business_date          AS                             reportDate,
                   area_id                AS                             areacode,
                   COUNT(order_id)        AS                             orderIdCount,
                   SUM(contract_amount)   AS                             contractAmountSum,
                   SUM(receive_amount)    AS                             receiveAmount,
                   SUM(qq_receive_amount) AS                             earlyReceiveAmount,
                   sum(CASE WHEN product_type = '软装包' THEN 1 ELSE 0 END) software,
                   sum(CASE WHEN product_type = '智能包' THEN 1 ELSE 0 END) zhineng,
                   sum(CASE WHEN product_type = '硬装包' THEN 1 ELSE 0 END) yingzhuang,
                   sum(CASE WHEN product_type = '家电包' THEN 1 ELSE 0 END) jiadian
            FROM jsczb_linbao
            WHERE STATUS = 1
              AND YEAR(business_date) = YEAR('2021-07-12')) c) kk,
     (SELECT IFNULL(SUM(all_goods_order_cnt_not_back), 0) eCommerceAmount,
             IFNULL(SUM(all_goods_money_pay_not_back), 0) eCommerceNum
      FROM jsczb_member_order
      WHERE YEAR(create_date) = YEAR('2021-07-12')) jj,
     (SELECT nps autoNfs, nps_update_date autoNpsUpdateDate FROM jsczb_robot_auto_summary LIMIT 1) ll,
     (SELECT SUM(mileage)            mileage,
             SUM(operation_duration) operationDuration,
             SUM(order_count)        orderCount,
             SUM(proprietor_time)    proprietorTime,
             SUM(customer_time)      customerTime,
             SUM(visitor_time)       visitorTime
      FROM jsczb_robot_auto_report
      WHERE time_scale = 'year'
        AND `time` = YEAR('2021-07-12')
        AND area_id = 0) mm,
     (SELECT SUM(mileage)                                                            delightMileage,
             SUM(order_count)                                                        delightOrderCount,
             SUM(batch_count)                                                        delightBatchCount,
             SUM(promote_customer)                                                   delightPromoteCustomer,
             SUM(non_promote_customer) delightNonPromoteCustomer,
             SUM(order_duration)                                                     delightOrderDuration,
             SUM(delivery_duration)                                                  delightDeliveryDuration
      FROM jsczb_robot_delight_report
      WHERE time_scale = 'year'
        AND `time` = YEAR('2021-07-12')
        AND area_id = 0) pp,
     (SELECT nps delightNfs, nps_update_date delightNpsUpdateDate FROM jsczb_robot_delight_summary) nn,
     (SELECT SUM(subscribing_amount) targetSubscribingAmount,
             SUM(contract_amount)    targetContractAmount,
             SUM(received_money)     targetReceivedMoney
      FROM jsczb_target_year
      WHERE `year` = year('2021-07-12')) cc,
     (SELECT SUM(gonghuo_amount) targetGonghuoAmount
      FROM jsczb_gonghuo_target_month
      WHERE LEFT(`month`, 4) = YEAR('2021-07-12')) dd,
     (SELECT sum(reg_user_cnt) registerNum FROM jsczb_member_reg WHERE left(create_date, 4) = year('2021-07-12')) kmk;
```

---

### 业绩分析

#### 业绩走势
![](/etl-docs/img/IMG_1702.PNG)

```sql
SELECT IFNULL(a.reportMonth, '2021-07')  reportMonth,
       a.subscribingAmount       subscribingAmount,
       a.contractAmount          contractAmount,
       a.receivedMoney           receivedMoney,
       a.gonghuoAmount           gonghuoAmount,
       b.targetSubscribingAmount subscribingAmountTarget,
       b.targetContractAmount    contractAmountTarget,
       b.targetReceivedMoney     receivedMoneyTarget,
       c.targetGonghuoAmount     gonghuoAmountTarget
FROM (SELECT reportMonth,
             SUM(subscribingAmount) AS subscribingAmount,
             SUM(contractAmount)    AS contractAmount,
             SUM(receivedMoney)     AS receivedMoney,
             SUM(gonghuoAmount)     AS gonghuoAmount
      FROM jsczb_month_report
      WHERE reportMonth = '2021-07'
        AND reportDate = (SELECT MAX(reportDate) FROM jsczb_month_report WHERE reportMonth = '2021-07')) a,
     (SELECT SUM(subscribing_amount) targetSubscribingAmount,
             SUM(contract_amount)    targetContractAmount,
             SUM(received_money)     targetReceivedMoney
      FROM jsczb_target_month
      WHERE `month` = '2021-07') b,
     (SELECT SUM(gonghuo_amount) targetGonghuoAmount FROM jsczb_gonghuo_target_month WHERE `month` = '2021-07') c;
     
-- 其它月份类似，只是日期不同
```

---

#### 销售占比
![](/etl-docs/img/IMG_1705.PNG)

① 得到区域代码

```sql
SELECT pk_area AS areacode, areaname FROM v_md_area WHERE parentid IS NOT NULL AND dr = 0 ORDER BY sort;
```

② 

```sql
SELECT contractAmount, mp.`project_name`
FROM (SELECT SUM(contractAmount) contractAmount, projectId
      FROM jsczb_year_report
      WHERE reportDate IN (SELECT MAX(reportDate) FROM jsczb_year_report WHERE reportYear = year('2021-07-12'))
      GROUP BY projectId) a
         INNER JOIN md_projectinfo mp ON a.projectId = mp.id_project
WHERE mp.`belong_area` = '1101';
```

---

### 业绩排名

#### 区域-日-认购

![](/etl-docs/img/IMG_1706.PNG)

业绩排名这部分 UI，在选中“区域” 或 “项目” 后，再选中日期，然后是“认购”、“签约”，或“回款”。这部分的实现逻辑是，先返回排名的一级菜单。接着返回二级菜单子项目所有内容，前端根据区域代码再插入子项目数据到对应的一级菜单下。

```sql
-- 先获得第一层菜单的数据，区域代码和区域公司名称
SELECT ma.pk_area               areacode,
       ma.`areaname`            areaname,
       SUM(a.subscribingNum)    subscribingNum,
       SUM(a.subscribingAmount) subscribingAmount,
       SUM(a.contractNum)       contractNum,
       SUM(a.contractAmount)    contractAmount,
       SUM(a.contractAmountN)   contractAmountN,
       SUM(a.contractNumN)      contractNumN,
       SUM(a.receivedMoney)     receivedMoney,
       SUM(a.receivedMoneyN)    receivedMoneyN,
       SUM(a.subscribingAmounN) subscribingAmounN,
       SUM(a.gonghuoNum)        gonghuoNum,
       SUM(a.gonghuoAmount)     gonghuoAmount
FROM (SELECT id_project FROM v_md_projectinfo) e
         LEFT JOIN (SELECT projectId,
                           SUM(subscribingNum)      AS subscribingNum,
                           SUM(subscribingAmount)   AS subscribingAmount,
                           SUM(contractNum)         AS contractNum,
                           SUM(contractAmount)      AS contractAmount,
                           SUM(contractAmount_n)    AS contractAmountN,
                           SUM(contractNum_n)       AS contractNumN,
                           SUM(receivedMoney)       AS receivedMoney,
                           SUM(receivedMoney_n)     AS receivedMoneyN,
                           SUM(subscribingAmount_n) AS subscribingAmounN,
                           SUM(gonghuoAmount)       AS gonghuoAmount,
                           SUM(gonghuoNum)          AS gonghuoNum
                    FROM jsczb_daily_report
                    WHERE reportDate = '2021-07-13'
                    GROUP BY projectId) a ON e.id_project = a.projectId
         LEFT JOIN (SELECT id_project, belong_area, project_name FROM md_projectinfo) d ON e.id_project = d.id_project
         LEFT JOIN md_area ma ON ma.pk_area = d.belong_area
GROUP BY ma.pk_area;
```

```sql
-- 项目代码和所属区域以及名称
SELECT vmp.project_name projectName,
       vmp.project_code projectCode,
       vmp.id_project idProject,
       vmp.belong_area belongArea,
       vmp.belong_provinces belongProvinces,
       vmp.belong_city belongCity,
       vma.areaname areaName
FROM v_md_projectinfo vmp
         LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN (
                       'P0001',
                       'P0002',
                       'P0003',
                       'P0004',
                       'P0005',
                       'P0006',
                       'P0007',
                       'P0009',
                       'P0010',
                       'P0011',
                       'P0012',
                       'P0018',
                       'P0019',
                       'P0026',
                       'P0046',
                       'P0048',
                       'P0062',
                       'P0063',
                       'P0064',
                       'P0065',
                       'P0067',
                       'P0071',
                       'P0076',
                       'P0084',
                       'P0085',
                       'P0086',
                       'P0087',
                       'P0089',
                       'P0090',
                       'P0091',
                       'P0093',
                       'P0094',
                       'P0095',
                       'P0096',
                       'P0097',
                       'P0098',
                       'P0099',
                       'P0100',
                       'P0106',
                       'P0109',
                       'P0110',
                       'P0111',
                       'P0112',
                       'P0113',
                       'P0117',
                       'P0118',
                       'P0120',
                       'P0123',
                       'P0124'
    );
```

```sql
-- 不太清楚为什么要这个查询
SELECT t.md_area_code FROM md_area_uc_code t WHERE t.is_enabled = 1 AND t.uc_code IN (?);
```

接下来是认购的查询：

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY subscribingAmount DESC;
```

---

#### 区域-日-签约

![](/etl-docs/img/IMG_1707.PNG)

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY contractAmount DESC;
```

---

#### 区域-日-回款

![](/etl-docs/img/IMG_1708.PNG)

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY receivedMoney DESC;
```

---

#### 区域-周-认购

![](/etl-docs/img/IMG_1709.PNG)

```sql
SELECT ma.pk_area               areacode,
       ma.`areaname`            areaname,
       SUM(a.subscribingNum)    subscribingNum,
       SUM(a.subscribingAmount) subscribingAmount,
       SUM(a.contractNum)       contractNum,
       SUM(a.contractAmount)    contractAmount,
       SUM(a.contractAmountN)   contractAmountN,
       SUM(a.contractNumN)      contractNumN,
       SUM(a.receivedMoney)     receivedMoney,
       SUM(a.receivedMoneyN)    receivedMoneyN,
       SUM(a.subscribingAmounN) subscribingAmounN,
       SUM(a.gonghuoNum)        gonghuoNum,
       SUM(a.gonghuoAmount)     gonghuoAmount
FROM (SELECT id_project FROM v_md_projectinfo) e
         LEFT JOIN (SELECT projectId,
                           SUM(subscribingNum)      AS subscribingNum,
                           SUM(subscribingAmount)   AS subscribingAmount,
                           SUM(contractNum)         AS contractNum,
                           SUM(contractAmount)      AS contractAmount,
                           SUM(contractAmount_n)    AS contractAmountN,
                           SUM(contractNum_n)       AS contractNumN,
                           SUM(receivedMoney)       AS receivedMoney,
                           SUM(receivedMoney_n)     AS receivedMoneyN,
                           SUM(subscribingAmount_n) AS subscribingAmounN,
                           SUM(gonghuoAmount)       AS gonghuoAmount,
                           SUM(gonghuoNum)          AS gonghuoNum
                    FROM jsczb_daily_report
                    WHERE YEARWEEK(reportDate, 1) = '202128'
                    GROUP BY projectId) a ON e.id_project = a.projectId
         LEFT JOIN (SELECT id_project, belong_area, project_name FROM md_projectinfo) d ON e.id_project = d.id_project
         LEFT JOIN md_area ma ON ma.pk_area = d.belong_area
GROUP BY ma.pk_area;
```

```sql
SELECT vmp.project_name projectName,
    vmp.project_code projectCode,
    vmp.id_project idProject,
    vmp.belong_area belongArea,
    vmp.belong_provinces belongProvinces,
    vmp.belong_city belongCity,
    vma.areaname areaName
FROM v_md_projectinfo vmp
    LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN (
        'P0001',
        'P0002',
        'P0003',
        'P0004',
        'P0005',
        'P0006',
        'P0007',
        'P0009',
        'P0010',
        'P0011',
        'P0012',
        'P0018',
        'P0019',
        'P0026',
        'P0046',
        'P0048',
        'P0062',
        'P0063',
        'P0064',
        'P0065',
        'P0067',
        'P0071',
        'P0076',
        'P0084',
        'P0085',
        'P0086',
        'P0087',
        'P0089',
        'P0090',
        'P0091',
        'P0093',
        'P0094',
        'P0095',
        'P0096',
        'P0097',
        'P0098',
        'P0099',
        'P0100',
        'P0106',
        'P0109',
        'P0110',
        'P0111',
        'P0112',
        'P0113',
        'P0117',
        'P0118',
        'P0120',
        'P0123',
        'P0124'
    );
```

```sql
SELECT t.md_area_code FROM md_area_uc_code t WHERE t.is_enabled = 1 AND t.uc_code IN ('10001')
```

---

#### 区域-周-签约

![](/etl-docs/img/IMG_1710.PNG)

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE YEARWEEK(reportDate, 1) = '202128'
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE YEARWEEK(`month`, 1) = '202128'
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY contractAmount DESC;
```

---

#### 区域-周-回款

![](/etl-docs/img/IMG_1711.PNG)

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE YEARWEEK(reportDate, 1) = '202128'
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE YEARWEEK(`month`, 1) = '202128'
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY receivedMoney DESC;
```

---

#### 区域-月-认购

![](/etl-docs/img/IMG_1712.PNG)

```sql
SELECT ma.pk_area                     areacode,
       ma.`areaname`                  areaname,
       SUM(a.subscribingNum)          subscribingNum,
       SUM(a.subscribingAmount)       subscribingAmount,
       SUM(a.contractNum)             contractNum,
       SUM(a.contractAmount)          contractAmount,
       SUM(a.contractAmountN)         contractAmountN,
       SUM(a.contractNumN)            contractNumN,
       SUM(a.receivedMoney)           receivedMoney,
       SUM(a.receivedMoneyN)          receivedMoneyN,
       SUM(a.subscribingAmounN)       subscribingAmounN,
       SUM(a.gonghuoNum)              gonghuoNum,
       SUM(a.gonghuoAmount)           gonghuoAmount,
       SUM(b.targetSubscribingAmount) targetSubscribingAmount,
       SUM(b.targetContractAmount)    targetContractAmount,
       SUM(b.targetReceivedMoney)     targetReceivedMoney,
       SUM(c.targetGonghuoAmount)     targetGonghuoAmount
FROM (SELECT id_project FROM v_md_projectinfo) e
         LEFT JOIN (SELECT projectId,
                           SUM(subscribingNum)     AS subscribingNum,
                           SUM(subscribingAmount)  AS subscribingAmount,
                           SUM(contractNum)        AS contractNum,
                           SUM(contractAmount)     AS contractAmount,
                           SUM(contractAmount_n)   AS contractAmountN,
                           SUM(contractNum_n)      AS contractNumN,
                           SUM(receivedMoney)      AS receivedMoney,
                           SUM(receivedMoney_n)    AS receivedMoneyN,
                           SUM(subscribingAmoun_n) AS subscribingAmounN,
                           SUM(gonghuoAmount)      AS gonghuoAmount,
                           SUM(gonghuoNum)         AS gonghuoNum
                    FROM jsczb_month_report
                    WHERE reportDate = DATE_FORMAT('2021-07-13', '%Y-%m-%d')
                    GROUP BY projectId) a ON e.id_project = a.projectId
         LEFT JOIN (SELECT project_id,
                           SUM(subscribing_amount) targetSubscribingAmount,
                           SUM(contract_amount)    targetContractAmount,
                           SUM(received_money)     targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = date_format('2021-07-13', "%Y-%m")
                    GROUP BY project_id) b ON e.id_project = b.project_id
         LEFT JOIN (SELECT id, SUM(gonghuo_amount) targetGonghuoAmount
                    FROM jsczb_gonghuo_target_month
                    WHERE `month` = DATE_FORMAT('2021-07-13', "%Y-%m")
                    GROUP BY id) c ON e.id_project = c.id
         LEFT JOIN (SELECT id_project, belong_area, project_name FROM md_projectinfo) d ON e.id_project = d.id_project
         LEFT JOIN md_area ma ON ma.pk_area = d.belong_area
GROUP BY ma.pk_area;
```

```sql
SELECT vmp.project_name projectName,
    vmp.project_code projectCode,
    vmp.id_project idProject,
    vmp.belong_area belongArea,
    vmp.belong_provinces belongProvinces,
    vmp.belong_city belongCity,
    vma.areaname areaName
FROM v_md_projectinfo vmp
    LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN (
        'P0001',
        'P0002',
        'P0003',
        'P0004',
        'P0005',
        'P0006',
        'P0007',
        'P0009',
        'P0010',
        'P0011',
        'P0012',
        'P0018',
        'P0019',
        'P0026',
        'P0046',
        'P0048',
        'P0062',
        'P0063',
        'P0064',
        'P0065',
        'P0067',
        'P0071',
        'P0076',
        'P0084',
        'P0085',
        'P0086',
        'P0087',
        'P0089',
        'P0090',
        'P0091',
        'P0093',
        'P0094',
        'P0095',
        'P0096',
        'P0097',
        'P0098',
        'P0099',
        'P0100',
        'P0106',
        'P0109',
        'P0110',
        'P0111',
        'P0112',
        'P0113',
        'P0117',
        'P0118',
        'P0120',
        'P0123',
        'P0124'
    );
```

```sql
SELECT t.md_area_code FROM md_area_uc_code t WHERE t.is_enabled = 1 AND t.uc_code IN ('10001')
```

```sql
-- 业绩排名-月-认购
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_month_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY subscribingAmount DESC;
```

---

#### 区域-月-签约

![](/etl-docs/img/IMG_1713.PNG)

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_month_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY contractAmount DESC;
```

---

#### 区域-月-回款

![](/etl-docs/img/IMG_1714.PNG)

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_month_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY receivedMoney DESC;
```

---

#### 区域-年-认购

![](/etl-docs/img/IMG_1715.PNG)

```sql
SELECT ma.pk_area                              areacode,
       ma.`areaname`                           areaname,
       SUM(DISTINCT a.subscribingNum)          subscribingNum,
       SUM(DISTINCT a.subscribingAmount)       subscribingAmount,
       SUM(DISTINCT a.contractNum)             contractNum,
       SUM(DISTINCT a.contractAmount)          contractAmount,
       SUM(DISTINCT a.contractAmountN)         contractAmountN,
       SUM(DISTINCT a.contractNumN)            contractNumN,
       SUM(DISTINCT a.receivedMoney)           receivedMoney,
       SUM(DISTINCT a.receivedMoneyN)          receivedMoneyN,
       SUM(DISTINCT a.subscribingAmounN)       subscribingAmounN,
       SUM(DISTINCT a.gonghuoNum)              gonghuoNum,
       SUM(DISTINCT a.gonghuoAmount)           gonghuoAmount,
       SUM(DISTINCT b.targetSubscribingAmount) targetSubscribingAmount,
       SUM(DISTINCT b.targetContractAmount)    targetContractAmount,
       SUM(DISTINCT b.targetReceivedMoney)     targetReceivedMoney,
       ap.shidi_profit_p                       profitsRate,
       ap.shidi_profit                         profits,
       SUM(DISTINCT c.targetGonghuoAmount)     targetGonghuoAmount
FROM (SELECT id_project FROM v_md_projectinfo) e
         LEFT JOIN (SELECT projectId,
                           SUM(subscribingNum)      AS subscribingNum,
                           SUM(subscribingAmount)   AS subscribingAmount,
                           SUM(contractNum)         AS contractNum,
                           SUM(contractAmount)      AS contractAmount,
                           SUM(contractAmount_n)    AS contractAmountN,
                           SUM(contractNum_n)       AS contractNumN,
                           SUM(receivedMoney)       AS receivedMoney,
                           SUM(receivedMoney_n)     AS receivedMoneyN,
                           SUM(subscribingAmount_n) AS subscribingAmounN,
                           SUM(gonghuoAmount)       AS gonghuoAmount,
                           SUM(gonghuoNum)          AS gonghuoNum
                    FROM jsczb_year_report
                    WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                    GROUP BY projectId) a ON a.projectId = e.id_project
         LEFT JOIN (SELECT project_id,
                           SUM(subscribing_amount) targetSubscribingAmount,
                           SUM(contract_amount)    targetContractAmount,
                           SUM(received_money)     targetReceivedMoney
                    FROM jsczb_target_year
                    WHERE `year` = YEAR('2021-07-13')
                    GROUP BY project_id) b ON e.id_project = b.project_id
         LEFT JOIN (SELECT SUM(gonghuo_amount) targetGonghuoAmount, id
                    FROM jsczb_gonghuo_target_month
                    WHERE LEFT(`month`, 4) = DATE_FORMAT('2021-07-13', "%Y")
                    GROUP BY id) c ON e.id_project = c.id
         LEFT JOIN (SELECT id_project, belong_area, project_name FROM md_projectinfo) d ON e.id_project = d.id_project
         LEFT JOIN md_area ma ON ma.pk_area = d.belong_area
         LEFT JOIN (SELECT *
                    FROM jsczb_profit_class_lv3
                    WHERE report_month =
                          (SELECT max(report_month) FROM jsczb_profit_class_lv3 WHERE report_year = year('2021-07-13'))) ap
                   ON ap.id_lv3 = ma.pk_area
GROUP BY ma.pk_area;
```

```sql
SELECT vmp.project_name projectName,
    vmp.project_code projectCode,
    vmp.id_project idProject,
    vmp.belong_area belongArea,
    vmp.belong_provinces belongProvinces,
    vmp.belong_city belongCity,
    vma.areaname areaName
FROM v_md_projectinfo vmp
    LEFT JOIN v_md_area vma ON vma.areacode = vmp.belong_area
WHERE project_code IN (
        'P0001',
        'P0002',
        'P0003',
        'P0004',
        'P0005',
        'P0006',
        'P0007',
        'P0009',
        'P0010',
        'P0011',
        'P0012',
        'P0018',
        'P0019',
        'P0026',
        'P0046',
        'P0048',
        'P0062',
        'P0063',
        'P0064',
        'P0065',
        'P0067',
        'P0071',
        'P0076',
        'P0084',
        'P0085',
        'P0086',
        'P0087',
        'P0089',
        'P0090',
        'P0091',
        'P0093',
        'P0094',
        'P0095',
        'P0096',
        'P0097',
        'P0098',
        'P0099',
        'P0100',
        'P0106',
        'P0109',
        'P0110',
        'P0111',
        'P0112',
        'P0113',
        'P0117',
        'P0118',
        'P0120',
        'P0123',
        'P0124'
    );
```

```sql
SELECT t.md_area_code FROM md_area_uc_code t WHERE t.is_enabled = 1 AND t.uc_code IN ('10001')
```

```sql
-- 业绩排名-年-区域-认购
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_year_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_year
                    WHERE `year` = YEAR('2021-07-13')
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY subscribingAmount DESC;
```

---

#### 区域-年-签约

![](/etl-docs/img/IMG_1716.PNG)

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_year_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_year
                    WHERE `year` = YEAR('2021-07-13')
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY contractAmount DESC;
```

---

#### 区域-年-回款

![](/etl-docs/img/IMG_1717.PNG)

```sql
SELECT belong_area  AS areaCode,
       id_project   AS projectId,
       project_name AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM v_md_projectinfo mp
         RIGHT JOIN (SELECT projectId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_year_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY projectId) jmr ON mp.id_project = jmr.projectId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_year
                    WHERE `year` = YEAR('2021-07-13')
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
GROUP BY mp.id_project, belong_area
ORDER BY receivedMoney DESC;
```

---

#### 项目-日-认购

![](/etl-docs/img/IMG_1718.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       contractNum,
       contractAmount,
       receivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
ORDER BY subscribingAmount DESC;
```

---

#### 项目-日-签约

![](/etl-docs/img/IMG_1719.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       contractNum,
       contractAmount,
       receivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
ORDER BY contractAmount DESC;
```

---

#### 项目-日-回款

![](/etl-docs/img/IMG_1720.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       contractNum,
       contractAmount,
       receivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
ORDER BY receivedMoney DESC;
```

---

#### 项目-周-认购

![](/etl-docs/img/IMG_1721.PNG)

```sql
-- 所有业态子项
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       contractNum,
       contractAmount,
       receivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE YEARWEEK(reportDate, 1) = '202128'
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
ORDER BY subscribingAmount DESC;
```

---

#### 项目-周-签约

![](/etl-docs/img/IMG_1722.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       contractNum,
       contractAmount,
       receivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE YEARWEEK(reportDate, 1) = '202128'
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
ORDER BY contractAmount DESC;
```

---

#### 项目-周-回款

![](/etl-docs/img/IMG_1723.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       contractNum,
       contractAmount,
       receivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_daily_report
                     WHERE YEARWEEK(reportDate, 1) = '202128'
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
ORDER BY receivedMoney DESC;
```

---

#### 项目-月-认购

![](/etl-docs/img/IMG_1724.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_month_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
ORDER BY subscribingAmount DESC;
```

---

#### 项目-月-签约

![](/etl-docs/img/IMG_1725.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_month_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
ORDER BY contractAmount DESC;
```

---

#### 项目-月-回款

![](/etl-docs/img/IMG_1726.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_month_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_month
                    WHERE `month` = left('2021-07-13', 7)
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
ORDER BY receivedMoney DESC;
```

#### 项目-年-认购

![](/etl-docs/img/IMG_1727.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_year_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_year
                    WHERE `year` = YEAR('2021-07-13')
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
ORDER BY subscribingAmount DESC;
```

#### 项目-年-签约

![](/etl-docs/img/IMG_1728.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_year_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_year
                    WHERE `year` = YEAR('2021-07-13')
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
ORDER BY contractAmount DESC;
```

#### 项目-年-回款

![](/etl-docs/img/IMG_1729.PNG)

```sql
SELECT jmr.projectId      AS projectId,
       bp.productTypeName AS projectName,
       subscribingNum,
       subscribingAmount,
       targetSubscribingAmount,
       contractNum,
       contractAmount,
       targetContractAmount,
       receivedMoney,
       targetReceivedMoney
FROM bijsc_producttype bp
         RIGHT JOIN (SELECT projectId,
                            productTypeId,
                            IFNULL(SUM(subscribingNum), 0)    AS subscribingNum,
                            IFNULL(SUM(subscribingAmount), 0) AS subscribingAmount,
                            IFNULL(SUM(contractNum), 0)       AS contractNum,
                            IFNULL(SUM(contractAmount), 0)    AS contractAmount,
                            IFNULL(SUM(receivedMoney), 0)     AS receivedMoney
                     FROM jsczb_year_report
                     WHERE reportDate = DATE_FORMAT('2021-07-13', "%Y-%m-%d")
                     GROUP BY productTypeId, projectId) jmr ON jmr.productTypeId = bp.productTypetId
         LEFT JOIN (SELECT project_id,
                           IFNULL(SUM(subscribing_amount), 0) AS targetSubscribingAmount,
                           IFNULL(SUM(contract_amount), 0)    AS targetContractAmount,
                           IFNULL(SUM(received_money), 0)     AS targetReceivedMoney
                    FROM jsczb_target_year
                    WHERE `year` = YEAR('2021-07-13')
                    GROUP BY project_id) jtm ON jmr.projectId = jtm.project_id
ORDER BY receivedMoney DESC;
```

