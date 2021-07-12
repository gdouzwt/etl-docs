---
layout: post
title:  "业绩看板"
date:   2021-07-12 11:19:52 +0800
---

### 指标概览

#### 日

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

#### 周

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

#### 月

![](/etl-docs/img/IMG_1700.PNG)

```sql
SELECT aa.subscribingNum subscribingNum,  -- 认购套数
    aa.subscribingAmount subscribingAmount,  -- 认购金额
    aa.linbaoNum linbaoNum,
    aa.linbaoAmount linbaoAmount,
    aa.vipNum vipNum,
    aa.vipAmount vipAmount,
    aa.contractNum contractNum,
    aa.contractAmount contractAmount,
    aa.contractAmountN contractAmountN,
    aa.subscribingAmountN subscribingAmountN,
    aa.contractNumN contractNumN,
    aa.receivedMoney receivedMoney,
    aa.receivedMoneyN receivedMoneyN,
    aa.gonghuoAmount gonghuoAmount,
    aa.gonghuoNum gonghuoNum,
    aa.yingshouAmountN yingshouAmountN,
    kk.orderIdCount orderIdCount,
    kk.contractAmountSum,
    kk.software,
    kk.zhineng,
    kk.yingzhuang,
    kk.jiadian,
    kk.earlyReceiveAmount,
    kmk.registerNum,
    kk.receiveAmount receiveAmount,
    jj.eCommerceNum eCommerceAmount,
    jj.eCommerceAmount eCommerceNum,
    ll.autoNfs autoNfs,
    ll.autoNpsUpdateDate autoNpsUpdateDate,
    mm.mileage mileage,
    mm.operationDuration operationDuration,
    mm.orderCount orderCount,
    mm.proprietorTime proprietorTime,
    mm.customerTime customerTime,
    mm.visitorTime,
    pp.delightMileage delightMileage,
    pp.delightOrderCount delightOrderCount,
    pp.delightBatchCount delightBatchCount,
    pp.delightPromoteCustomer delightPromoteCustomer,
    pp.delightNonPromoteCustomer delightNonPromoteCustomer,
    pp.delightOrderDuration delightOrderDuration,
    pp.delightDeliveryDuration delightDeliveryDuration,
    nn.delightNfs delightNfs,
    nn.delightNpsUpdateDate delightNpsUpdateDate,
    cc.targetSubscribingAmount targetSubscribingAmount,
    cc.targetContractAmount targetContractAmount,
    cc.targetReceivedMoney targetReceivedMoney,
    dd.targetGonghuoAmount targetGonghuoAmount
FROM (
        SELECT reportDate,
            SUM(subscribingNum) AS subscribingNum,
            SUM(subscribingAmount) AS subscribingAmount,
            SUM(subscribingAmoun_n) AS subscribingAmountN,
            SUM(linbaoNum) AS linbaoNum,
            SUM(linbaoAmount) AS linbaoAmount,
            SUM(vipNum) AS vipNum,
            SUM(vipAmount) AS vipAmount,
            SUM(contractNum) AS contractNum,
            SUM(contractAmount) AS contractAmount,
            SUM(contractAmount_n) AS contractAmountN,
            SU Jul 09 17 :33 :50 s - srpt - app3 - test cockpit [29001]: M(contractNum_n) AS contractNumN,
            SUM(receivedMoney) AS receivedMoney,
            SUM(receivedMoney_n) AS receivedMoneyN,
            SUM(gonghuoAmount) AS gonghuoAmount,
            SUM(gonghuoNum) AS gonghuoNum,
            SUM(yingshouAmount_n) AS yingshouAmountN
        FROM jsczb_month_report
        WHERE reportDate = DATE_FORMAT('2021-07-09', '%Y-%m-%d')
    ) aa,
    (
        SELECT IFNULL(SUM(c.orderIdCount), 0) orderIdCount,
            IFNULL(SUM(c.contractAmountSum), 0) contractAmountSum,
            IFNULL(SUM(c.receiveAmount), 0) receiveAmount,
            IFNULL(SUM(c.software), 0) software,
            IFNULL(SUM(c.zhineng), 0) zhineng,
            IFNULL(SUM(c.yingzhuang), 0) yingzhuang,
            IFNULL(SUM(c.jiadian), 0) jiadian,
            IFNULL(SUM(c.earlyReceiveAmount), 0) earlyReceiveAmount
        FROM (
                SELECT business_date AS reportDate,
                    area_id AS areacode,
                    COUNT(order_id) AS orderIdCount,
                    SUM(contract_amount) AS contractAmountSum,
                    SUM(receive_amount) AS receiveAmount,
                    SUM(qq_receive_amount) AS earlyReceiveAmount,
                    sum(
                        CASE
                            WHEN product_type = '软装包' THEN 1
                            ELSE 0
                        END
                    ) software,
                    sum(
                        CASE
                            WHEN product_type = '智能包' THEN 1
                            ELSE 0
                        END
                    ) zhineng,
                    sum(
                        CASE
                            WHEN product_type = '硬装包' THEN 1
                            ELSE 0
                        END
                    ) yingzhuang,
                    sum(
                        CASE
                            WHEN product_type = '家电包' THEN 1
                            ELSE 0
                        END
                    ) jiadian
                FROM jsczb_linbao
                WHERE STATUS = 1
                    AND LEFT(business_date, 7) = DATE_FORMAT('2021-07-09', '%Y-%m')
            ) c
    ) kk,
    (
        SELECT IFNULL(SUM(all_goods_order_cnt_not_back), 0) eCommerceAmount,
            IFNULL(SUM(all_goods_money_pay_not_back), 0) eCommerceNum
        FROM jsczb_member_order
        WHERE LEFT(create_date, 7) = DATE_FORMAT('2021-07-09', '%Y-%m')
    ) jj,
    (
        SELECT nps autoNfs,
            nps_update_date autoNpsUpdateDate
        FROM jsczb_robot_auto_summary
        LIMIT 1
    ) ll, (
        SELECT SUM(mileage) mileage,
            SUM(operation_duration) operationDuration,
            SUM(order_count) orderCount,
            SUM(proprietor_time) proprietorTime,
            SUM(customer_time) customerTime,
            SUM(visitor_time) visitorTime
        FROM jsczb_robot_auto_report
        WHERE time_scale = 'month'
            AND `time` = DATE_FORMAT('2021-07-09', '%Y-%m')
            AND area_id = 0
    ) mm,
    (
        SELECT SUM(mileage) delightMileage,
            SUM(order_count) delightOrderCount,
            SUM(batch_count) delightBatchCount,
            SUM(promote_customer) delightPromoteCustomer,
            SUM(
                non_promote_c Jul 09 17 :33 :50 s - srpt - app3 - test cockpit [29001]: ustomer
            ) delightNonPromoteCustomer,
            SUM(order_duration) delightOrderDuration,
            SUM(delivery_duration) delightDeliveryDuration
        FROM jsczb_robot_delight_report
        WHERE time_scale = 'month'
            AND `time` = DATE_FORMAT('2021-07-09', '%Y-%m')
            AND area_id = 0
    ) pp,
    (
        SELECT nps delightNfs,
            nps_update_date delightNpsUpdateDate
        FROM jsczb_robot_delight_summary
    ) nn,
    (
        SELECT SUM(subscribing_amount) targetSubscribingAmount,
            SUM(contract_amount) targetContractAmount,
            SUM(received_money) targetReceivedMoney
        FROM jsczb_target_month
        WHERE `month` = DATE_FORMAT('2021-07-09', '%Y-%m')
    ) cc,
    (
        SELECT SUM(gonghuo_amount) targetGonghuoAmount
        FROM jsczb_gonghuo_target_month
        WHERE `month` = DATE_FORMAT('2021-07-09', '%Y-%m')
    ) dd,
    (
        SELECT sum(reg_user_cnt) registerNum
        FROM jsczb_member_reg
        WHERE LEFT(create_date, 7) = DATE_FORMAT('2021-07-09', '%Y-%m')
    ) kmk;
```

#### 年

![](/etl-docs/img/IMG_1701.PNG)

### 业绩分析

#### 业绩走势-认购
![](/etl-docs/img/IMG_1702.PNG)

#### 业绩走势-签约
![](/etl-docs/img/IMG_1703.PNG)

#### 业绩走势-回款
![](/etl-docs/img/IMG_1704.PNG)

#### 销售占比
![](/etl-docs/img/IMG_1705.PNG)

### 业绩排名

#### 区域-日-认购

![](/etl-docs/img/IMG_1706.PNG)

#### 区域-日-签约

![](/etl-docs/img/IMG_1707.PNG)

#### 区域-日-回款

![](/etl-docs/img/IMG_1708.PNG)

#### 区域-周-认购

![](/etl-docs/img/IMG_1709.PNG)

#### 区域-周-签约

![](/etl-docs/img/IMG_1710.PNG)

#### 区域-周-回款

![](/etl-docs/img/IMG_1711.PNG)

#### 区域-月-认购

![](/etl-docs/img/IMG_1712.PNG)

#### 区域-月-签约

![](/etl-docs/img/IMG_1713.PNG)

#### 区域-月-回款

![](/etl-docs/img/IMG_1714.PNG)

#### 区域-年-认购

![](/etl-docs/img/IMG_1715.PNG)

#### 区域-年-签约

![](/etl-docs/img/IMG_1716.PNG)

#### 区域-年-回款

![](/etl-docs/img/IMG_1717.PNG)

#### 项目-日-认购

![](/etl-docs/img/IMG_1718.PNG)

#### 项目-日-签约

![](/etl-docs/img/IMG_1719.PNG)

#### 项目-日-回款

![](/etl-docs/img/IMG_1720.PNG)

#### 项目-周-认购

![](/etl-docs/img/IMG_1721.PNG)

#### 项目-周-签约

![](/etl-docs/img/IMG_1722.PNG)

#### 项目-周-回款

![](/etl-docs/img/IMG_1723.PNG)

#### 项目-月-认购

![](/etl-docs/img/IMG_1724.PNG)

#### 项目-月-签约

![](/etl-docs/img/IMG_1725.PNG)

#### 项目-月-回款

![](/etl-docs/img/IMG_1726.PNG)

#### 项目-年-认购

![](/etl-docs/img/IMG_1727.PNG)

#### 项目-年-签约

![](/etl-docs/img/IMG_1728.PNG)

#### 项目-年-回款

![](/etl-docs/img/IMG_1729.PNG)

