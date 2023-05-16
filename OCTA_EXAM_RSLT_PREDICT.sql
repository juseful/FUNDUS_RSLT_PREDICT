-- OCTA
with 
rslt as (-- 검사결과
        select /*+ index(a 3E3243333E2E143C28_i02) index(b 3C15332B3C20431528_pk) */
               a.ptno
             , a.ordr_ymd
             , a.exmn_cd
             , a.ordr_sno
             , a.spcm_no
             , a.rprt_dt
             , to_char(a.exrs_ctn) exrs_ctn
             , to_char(a.gros_rslt_ctn) gros_rslt_ctn
             , to_char(a.cnls_dx_ctn) cnls_dx_ctn
             , to_char(a.exrs_rmrk_ctn) exrs_rmrk_ctn
          from 스키마.3E3243333E2E143C28 a
             , 스키마.3C15332B3C20431528 b
         where a.rprt_dt between to_date('20220101','yyyymmdd') 
                             and to_date('20230331','yyyymmdd') + 0.99999
           and a.exmn_cd = 'SM0262'
           and nvl(a.exrs_updt_yn,'N') != 'Y'
           and a.ptno = b.ptno
           and a.ordr_ymd = b.ordr_ymd
           and a.ordr_sno = b.ordr_sno
           and b.codv_cd = 'G'
           and nvl(b.dc_dvsn_cd,'N') = 'N'
        )
, site_both as (-- 양안
                select a.*
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 1) b_01
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 2) b_02
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 3) b_03
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 4) b_04
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 5) b_05
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 6) b_06
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 7) b_07
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 8) b_08
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1, 9) b_09
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'양안',1,10) b_10
                  from rslt a
                )
, site_right as (-- 우안
                select a.*
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 1) r_01
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 2) r_02
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 3) r_03
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 4) r_04
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 5) r_05
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 6) r_06
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 7) r_07
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 8) r_08
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1, 9) r_09
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'우안',1,10) r_10
                  from rslt a
                )
, site_left as (-- 좌안
                select a.*
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 1) l_01
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 2) l_02
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 3) l_03
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 4) l_04
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 5) l_05
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 6) l_06
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 7) l_07
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 8) l_08
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1, 9) l_09
                     , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'좌안',1,10) l_10
                  from rslt a
                )
, rslt_normal as (-- 정상 결과코드값 출력
                select a.* 
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'E001'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R001'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L001'
                            else 'E001' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.b_01
                                            else 0
                                        end --) 
                                  from site_both x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_b
                             , (-- 우안 문구 자리값 찾기
                                select 
                                       case
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.r_01
                                            else 0
                                        end --) 
                                  from site_right x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_r
                             , (-- 좌안 문구 자리값 찾기
                                select 
                                       case
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정상')
                       ) a
             )
, rslt_macula_abnormal as (-- 망막 혈관 모양 이상 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O012'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R012'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L012'
                            else 'O012' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.b_01
                                            else 0
                                        end --) 
                                  from site_both x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_b
                             , (-- 우안 문구 자리값 찾기
                                select 
                                       case
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.r_01
                                            else 0
                                        end --) 
                                  from site_right x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_r
                             , (-- 좌안 문구 자리값 찾기
                                select 
                                       case
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈관모양이상')
                       ) a
             )
, rslt_impaired_retinal_microcirculation as (-- 망막 혈행 장애 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O013'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R013'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L013'
                            else 'O013' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.b_01
                                            else 0
                                        end --) 
                                  from site_both x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_b
                             , (-- 우안 문구 자리값 찾기
                                select 
                                       case
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.r_01
                                            else 0
                                        end --) 
                                  from site_right x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_r
                             , (-- 좌안 문구 자리값 찾기
                                select 
                                       case
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막혈행장애')
                       ) a
             )
, rslt_neovascularization as (-- 신생혈관 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O021'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R021'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L021'
                            else 'O021' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.b_01
                                            else 0
                                        end --) 
                                  from site_both x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_b
                             , (-- 우안 문구 자리값 찾기
                                select 
                                       case
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.r_01
                                            else 0
                                        end --) 
                                  from site_right x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_r
                             , (-- 좌안 문구 자리값 찾기
                                select 
                                       case
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신생혈관')
                       ) a
             )
, rslt_fundus_etc as (-- 안저 정밀(기타) 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O099'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R099'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L099'
                            else 'O099' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.b_01
                                            else 0
                                        end --) 
                                  from site_both x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_b
                             , (-- 우안 문구 자리값 찾기
                                select 
                                       case
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.r_01
                                            else 0
                                        end --) 
                                  from site_right x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_r
                             , (-- 좌안 문구 자리값 찾기
                                select 
                                       case
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(기타')
                       ) a
             )
select a.ptno
     , to_char(a.ordr_ymd,'yyyymmdd') ordr_ymd
     , a.exmn_cd
     , a.ordr_sno
     , a.spcm_no
     , to_char(a.rprt_dt,'yyyymmddhh24miss') rprt_dt
     , a.exrs_ctn
     , a.cnls_dx_ctn
     , a.alg_rslt_cd
  from (
        -- 정상
        select a.*
          from rslt_normal a
        union
        -- 망막 혈관 모양 이상
        select a.*
          from rslt_macula_abnormal a
        union
        -- 망막 혈행 장애
        select a.*
          from rslt_impaired_retinal_microcirculation a
        union
        -- 신생혈관
        select a.*
          from rslt_neovascularization a
        union
        -- 안저 정밀(기타)
        select a.*
          from rslt_fundus_etc a
       ) a
 group by a.ptno
     , to_char(a.ordr_ymd,'yyyymmdd')
     , a.exmn_cd
     , a.ordr_sno
     , a.spcm_no
     , to_char(a.rprt_dt,'yyyymmddhh24miss')
     , a.exrs_ctn
     , a.cnls_dx_ctn
     , a.alg_rslt_cd
 order by 1, 2, 3, 9
