-- FUNDUS EXAM
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
           and a.exmn_cd = 'SM0210'
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
, rslt_macular_degeneration as (-- 안저 정밀(황반변성) 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O034'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R025'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L025'
                            else 'O034' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'황반변성')
                       ) a
             )
, rslt_diabetic_retinopathy as (-- 당뇨병성 망막증 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O020'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R020'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L020'
                            else 'O020' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'당뇨병성망막증')
                       ) a
             )
, rslt_epiretinal_membrane as (-- 망막전막 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O016'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R016'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L016'
                            else 'O016' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'망막전막')
                       ) a
             )
, rslt_fundus_etc as (-- 안저 정밀(기타) 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O301'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R301'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L301'
                            else 'O301' /* 안구위치 문구 없으면 양안으로 간주 */
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
, rslt_media_opaque as (-- 매체혼탁 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O023'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R023'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L023'
                            else 'O023' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'매체혼탁')
                       ) a
             )
, rslt_glaucoma as (-- 녹내장 정밀 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O061'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R601'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L601'
                            else 'O061' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'녹내장정밀')
                       ) a
             )
, rslt_optic_nerve as (-- 시신경 정밀 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O032'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R105'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L027'
                            else 'O032' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'시신경정밀')
                       ) a
             )
, rslt_NFL_defect as (-- 신경섬유층 결손 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O040'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R040'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L040'
                            else 'O032' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'신경섬유층결손')
                       ) a
             )
, rslt_sighttest as (-- 시력 정밀(안경교정 안되면) 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O104'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R104'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L104'
                            else 'O104' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'정밀\(안경교정안되면')
                       ) a
             )
, rslt_tonometry as (-- 안압 정밀 결과코드값 출력
                select a.*
                     /* 양안,우안,좌안 중에서 최대인 값의 결과코드 출력 */
                     , case
                            when a.site_b > a.site_r and a.site_b > a.site_l then 'O201'
                            when a.site_r > a.site_b and a.site_r > a.site_l then 'R201'
                            when a.site_l > a.site_b and a.site_l > a.site_r then 'L201'
                            else 'O201' /* 안구위치 문구 없으면 양안으로 간주 */
                        end alg_rslt_cd
                  from (
                        select a.*
                             , regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') rslt_strt
                             , (-- 양안 문구 자리값 찾기 
                                select 
                                       case
                                            when x.b_10 != 0 and x.b_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_10
                                            when x.b_09 != 0 and x.b_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_09
                                            when x.b_08 != 0 and x.b_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_08
                                            when x.b_07 != 0 and x.b_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_07
                                            when x.b_06 != 0 and x.b_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_06
                                            when x.b_05 != 0 and x.b_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_05
                                            when x.b_04 != 0 and x.b_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_04
                                            when x.b_03 != 0 and x.b_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_03
                                            when x.b_02 != 0 and x.b_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_02
                                            when x.b_01 != 0 and x.b_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.b_01
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
                                            when x.r_10 != 0 and x.r_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_10
                                            when x.r_09 != 0 and x.r_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_09
                                            when x.r_08 != 0 and x.r_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_08
                                            when x.r_07 != 0 and x.r_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_07
                                            when x.r_06 != 0 and x.r_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_06
                                            when x.r_05 != 0 and x.r_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_05
                                            when x.r_04 != 0 and x.r_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_04
                                            when x.r_03 != 0 and x.r_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_03
                                            when x.r_02 != 0 and x.r_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_02
                                            when x.r_01 != 0 and x.r_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.r_01
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
                                            when x.l_10 != 0 and x.l_10 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_10
                                            when x.l_09 != 0 and x.l_09 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_09
                                            when x.l_08 != 0 and x.l_08 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_08
                                            when x.l_07 != 0 and x.l_07 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_07
                                            when x.l_06 != 0 and x.l_06 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_06
                                            when x.l_05 != 0 and x.l_05 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_05
                                            when x.l_04 != 0 and x.l_04 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_04
                                            when x.l_03 != 0 and x.l_03 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_03
                                            when x.l_02 != 0 and x.l_02 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_02
                                            when x.l_01 != 0 and x.l_01 < regexp_instr(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀') then x.l_01
                                            else 0
                                        end --) 
                                  from site_left x
                                 where a.ptno = x.ptno
                                   and a.ordr_ymd = x.ordr_ymd
                                   and a.exmn_cd = x.exmn_cd
                                   and a.ordr_sno = x.ordr_sno
                               ) site_l
                          from rslt a
                         where regexp_like(regexp_replace(a.cnls_dx_ctn,' ','',1,0),'안압정밀')
                       ) a
             )
, add_macular_degeneration as (-- 안저 정밀(황반변성), 안저 정밀(기타)코드 추가
                                select a.ptno, a.ordr_ymd, a.exmn_cd, a.ordr_sno, a.spcm_no, a.rprt_dt
                                     , a.exrs_ctn, a.gros_rslt_ctn, a.cnls_dx_ctn, a.exrs_rmrk_ctn
                                     , a.rslt_strt, a.site_b, a.site_r, a.site_l, a.rslt_cd_add
                                  from (
                                        select a.*
                                             , decode(a.alg_rslt_cd,'O034','O301'
                                                                  ,'R025','R301'
                                                                  ,'L025','L301'
                                                                  ) RSLT_CD_ADD
                                          from rslt_macular_degeneration a
                                       ) a
                              )
, add_diabetic_retinopathy as (-- 안저 정밀(당뇨병성 망막증), 안저 정밀(기타)코드 추가
                                select a.ptno, a.ordr_ymd, a.exmn_cd, a.ordr_sno, a.spcm_no, a.rprt_dt
                                     , a.exrs_ctn, a.gros_rslt_ctn, a.cnls_dx_ctn, a.exrs_rmrk_ctn
                                     , a.rslt_strt, a.site_b, a.site_r, a.site_l, a.rslt_cd_add
                                  from (
                                        select a.*
                                             , decode(a.alg_rslt_cd,'O020','O301'
                                                                  ,'R020','R301'
                                                                  ,'L020','L301'
                                                                  ) RSLT_CD_ADD
                                          from rslt_diabetic_retinopathy a
                                       ) a
                              )
, add_epiretinal_membrane as (-- 안저 정밀(망막전막), 안저 정밀(기타)코드 추가
                                select a.ptno, a.ordr_ymd, a.exmn_cd, a.ordr_sno, a.spcm_no, a.rprt_dt
                                     , a.exrs_ctn, a.gros_rslt_ctn, a.cnls_dx_ctn, a.exrs_rmrk_ctn
                                     , a.rslt_strt, a.site_b, a.site_r, a.site_l, a.rslt_cd_add
                                  from (
                                        select a.*
                                             , decode(a.alg_rslt_cd,'O016','O301'
                                                                  ,'R016','R301'
                                                                  ,'L016','L301'
                                                                  ) RSLT_CD_ADD
                                          from rslt_epiretinal_membrane a
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
        -- 황반변성 
        select a.*
          from rslt_macular_degeneration a
        union 
        -- 당뇨병성 망막증
        select a.*
          from rslt_diabetic_retinopathy a
        union 
        -- 망막전막
        select a.*
          from rslt_epiretinal_membrane a
        union 
        -- 안저 정밀(기타)
        select a.*
          from rslt_fundus_etc a
        union
        -- 매체혼탁
        select a.*
          from rslt_media_opaque a
        union
        -- 녹내장 정밀
        select a.*
          from rslt_glaucoma a
        union
        -- 시신경 정밀
        select a.*
          from rslt_optic_nerve a
        union
        -- 신경섬유층 결손
        select a.*
          from rslt_NFL_defect a
        union
        -- 시력 정밀 
        select a.*
          from rslt_sighttest a
        union 
        -- 안압 정밀
        select a.*
          from rslt_tonometry a
        union
        -- 안저 정밀(황반변성), 안저 정밀(기타)코드 추가
        select a.*
          from add_macular_degeneration a
        union
        -- 안저 정밀(당뇨병성 망막증), 안저 정밀(기타)코드 추가
        select a.*
          from add_diabetic_retinopathy a
        union
        -- 안저 정밀(망막전막), 안저 정밀(기타)코드 추가
        select a.*
          from add_epiretinal_membrane a
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
