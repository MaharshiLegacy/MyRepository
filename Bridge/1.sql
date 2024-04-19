select
	ORG.DRO_ID,
	ORG.ZONE_ID,
	ORG.ZONE_NAME,
	ORG.DRO_NAME,
	NVL(SUM(TOTAL_APP.TOTAL_NO_OF_APPLICATIONS), 0) as TOTAL_NO_OF_APPLICATIONS,
	NVL(Payment.Total_Amount, 0)as Total_Amount,
	NVL(SUM(TOTAL_APP.TOTAL_NO_OF_APPLICATIONS_APPROVED), 0) as TOTAL_NO_OF_APPLICATIONS_APPROVED,
	NVL(SUM(TOTAL_FEMALE.TOTAL_APP_WITH_FEMALE_OWNERS), 0) as TOTAL_APP_WITH_FEMALE_OWNERS,
	NVL(SUM(TOTAL_FEMALE.TOTAL_APP_APPROVED_WITH_FEMALE_OWNERS), 0) as TOTAL_APP_APPROVED_WITH_FEMALE_OWNERS,
	AVG(AVG_TIME_TAKEN) as AVG_TIME_TAKEN,
	PERCENTILE_CONT(0.5) within group(
order by
	(MEDIAN)) as MEDIAN,
	MIN(MIN_TIME_TAKEN) as MIN_TIME_TAKEN,
	MAX(MAX_TIME_TAKEN) as MAX_TIME_TAKEN
from
	(
	select
		DRO.ORGANIZATION_ID as DRO_ID, ZONE_DTL.ORGANIZATION_ID as ZONE_ID, DRO_DTL.ORGANIZATION_NAME as DRO_NAME, ZONE_DTL.ORGANIZATION_NAME as ZONE_NAME
	from
		FR_ORG_ORGANIZATION_MST DRO
	join FR_ORG_ORGANIZATION_MST zone on
		DRO.PRNT_ORGANIZATION_ID = ZONE.ORGANIZATION_ID
		and DRO.ORGANIZATION_TYPE = 60
		and DRO.ACTIVE_FLAG = 1
		and ZONE.ACTIVE_FLAG = 1
	join FR_ORG_ORGANIZATION_DTLS DRO_DTL on
		DRO_DTL.ORGANIZATION_ID = DRO.ORGANIZATION_ID
		and DRO_DTL.LANG_ID = 1
	join FR_ORG_ORGANIZATION_DTLS ZONE_DTL on
		ZONE_DTL.ORGANIZATION_ID = ZONE.ORGANIZATION_ID
		and ZONE_DTL.LANG_ID = 1 ) ORG
left outer join (
	select
		1 as TOTAL_NO_OF_APPLICATIONS,
		case
			when REQ.STATUS in(1130256, 1130075) then 1
			else 0
		end as TOTAL_NO_OF_APPLICATIONS_APPROVED, REQ.SRG_REG_ID, REQ.STATUS, REG.REGDISTID, REQ.temp_app_no
	from
		SRG_TRN_APP_REQUEST_DTL REQ
	join SRG_TRN_REGISTRATION_DTLS REG on
		REQ.SRG_REG_ID = REG.SRG_REG_ID
	where
		REQ.REQUEST_TYPE in(1130201, 1130329)
		and REGDISTID not in (10331)
		and REQ.CRT_DT between '01-04-2024' and '17-04-2024' ) TOTAL_APP on
	TOTAL_APP.REGDISTID = ORG.DRO_ID
left outer join (
select
		sum(ptd_total_amt) as total_amount,
		case when (mst.organization_type  = 65) then MST.PRNT_ORGANIZATION_ID else  mst.ORGANIZATION_ID END   as DRO_ID
	from
		SRG_TRN_APP_REQUEST_DTL REQ
	join SRG_TRN_REGISTRATION_DTLS REG on
		REQ.SRG_REG_ID = REG.SRG_REG_ID
	join pmt_transaction_dtls pmt on
		pmt.ptd_ref_module_ack_no = req.temp_app_no
	left outer join FR_ORG_ORGANIZATION_MST MST on MST.ORGANIZATION_ID=PMT.SRO_ID
	where
		req.request_type in (1130201, 1130329)
		and req.status in (1130075, 1130256)
		and pmt.ptd_bank_pmt_status = 'S'
		and REQ.CRT_DT between '01-04-2024' and '17-04-2024'
	group by
		MST.PRNT_ORGANIZATION_ID,mst.ORGANIZATION_TYPE,mst.ORGANIZATION_ID
		) Payment on
	org.dro_id = payment.DRO_ID 
left outer join (
	select
		REG.REGDISTID as DRO , AVG((extract(EPOCH from (REGISTRATION_DATE - CRT_DT))/ 60)) as AVG_TIME_TAKEN, MIN((extract(EPOCH from (REGISTRATION_DATE - CRT_DT))/ 60)) as MIN_TIME_TAKEN, MAX((extract(EPOCH from (REGISTRATION_DATE - CRT_DT))/ 60)) as MAX_TIME_TAKEN , PERCENTILE_CONT(0.5) within group(
	order by
		(extract(EPOCH
	from
		( REGISTRATION_DATE - CRT_DT))/ 60)) as MEDIAN, REGDISTID
	from
		SRG_TRN_REGISTRATION_DTLS REG
	where
		REGDISTID not in (10331)
		and REGISTRATION_DATE is not null
		and REGISTRATION_DATE > CRT_DT
		and CRT_DT between '01-04-2024' and '17-04-2024'
	group by
		REG.REGDISTID ) TIME on
	TIME.DRO = ORG.DRO_ID
left outer join (
	select
		COUNT(distinct(MEMBER.SRG_REG_ID)) as TOTAL_APP_WITH_FEMALE_OWNERS, COUNT(distinct(case when REQ.STATUS in(1130256, 1130075) then REQ.SRG_REG_ID end ))as TOTAL_APP_APPROVED_WITH_FEMALE_OWNERS, MEMBER.SRG_REG_ID
	from
		SRG_TRN_APP_REQUEST_DTL REQ
	join SRG_TRN_MEMBER_DTLS member on
		REQ.SRG_REG_ID = MEMBER.SRG_REG_ID
	join SRG_TRN_PERSON_DTL PERSON on
		MEMBER.APP_PERSON_ID = PERSON.APP_PERSON_ID
	where
		PERSON.GENDER_ID = 7000003
		and MEMBER.DESIGNATION = 70020092
		and REQ.REQUEST_TYPE in(1130201, 1130329)
		and REQ.CRT_DT between '01-04-2024' and '17-04-2024'
	group by
		MEMBER.SRG_REG_ID ) TOTAL_FEMALE on
	TOTAL_APP.SRG_REG_ID = TOTAL_FEMALE.SRG_REG_ID
group by
	ORG.ZONE_NAME,
	ORG.DRO_NAME,
	ORG.DRO_ID,
	ORG.ZONE_ID,
	Payment.Total_Amount