#%%
import pandas as pd 
import re 
from datatable import fread
from sympy import N 
from tqdm import tqdm 
import numpy as np 

#%% 
# function 모음
# 의견, comment관련 결과 제외
def except_comments(input_txt):
    comment_text = re.compile(r"\s*▣ 의견[가-힣]*\s*")
    for m in re.finditer(comment_text,input_txt.lower()):
        comment_loc = m.start()
        return comment_loc

# 검사정보 및 소견 관련 결과 제외
def except_information(input_txt):
    diagnosis_text = re.compile(r"\s*▣ 결론 및 진단[가-힣]*\s*")
    for m in re.finditer(diagnosis_text,input_txt.lower()):
        diagnosis_loc = m.start()
        return diagnosis_loc

# text 결과 내용에 대한 예측
def diag_result_predict(results):
    diag_fin_result = []
    for result in results:
        if result[0] != "":
            diag_fin_result.append(result)
    return diag_fin_result

# 우안, 좌안, 양안 text 구분값
site_r01 = re.compile(r"\s*우안[가-힣]*\s*")
site_r02 = re.compile(r"\s*우측[가-힣]*\s*")
site_l01 = re.compile(r"\s*좌안[가-힣]*\s*")
site_l02 = re.compile(r"\s*좌측[가-힣]*\s*")
site_o01 = re.compile(r"\s*양안[가-힣]*\s*")
site_o02 = re.compile(r"\s*양측[가-힣]*\s*")

# 각 위치 관련 문구 찾기
def result_site_r(input_txt):
    site_loc_list = []
    if re.search(site_r01, input_txt) != None: 
        for m in re.finditer(site_r01,input_txt):
            site_loc_list.append(m.start())
        return max(site_loc_list), "우안"
    elif re.search(site_r02, input_txt) != None: 
        for m in re.finditer(site_r02,input_txt):
            site_loc_list.append(m.start())
        return max(site_loc_list), "우안"
        
def result_site_l(input_txt):
    site_loc_list = []
    if re.search(site_l01, input_txt) != None: 
        for m in re.finditer(site_l01,input_txt):
            site_loc_list.append(m.start())
        return max(site_loc_list), "좌안"
    elif re.search(site_l02, input_txt) != None: 
        for m in re.finditer(site_l02,input_txt):
            site_loc_list.append(m.start())
        return max(site_loc_list), "좌안"

def result_site_o(input_txt):
    site_loc_list = []
    if re.search(site_o01, input_txt) != None: 
        for m in re.finditer(site_o01,input_txt):
            site_loc_list.append(m.start())
        return max(site_loc_list), "양안"
    elif re.search(site_o02, input_txt) != None: 
        for m in re.finditer(site_o02,input_txt):
            site_loc_list.append(m.start())
        return max(site_loc_list), "양안"

# 찾은 위치 중 해당 결과와 가장 가까운 위치를 최종 위치로 찾기
def find_site(input_txt):
    # max 값을 찾아야 하므로 비교를 위해서는 해당 site가 없을 경우도 정의가 필요함.
    # 설정해 주지 않았더니 '>' not supported between instances of 'tuple' and 'int' 에러가 발생함.
    # 에러의 원인은 type이 달라서 max 값 비교가 불가능하다
    right_site = (0,'') if result_site_r(input_txt)==None else result_site_r(input_txt)
    left_site  = (0,'') if result_site_l(input_txt)==None else result_site_l(input_txt)
    both_site  = (0,'') if result_site_o(input_txt)==None else result_site_o(input_txt)
    # 추가적으로 결과에 안구 위치가 명시되어 있지 않으면 양안으로 간주해야 함.
    if right_site == (0,'') and left_site == (0,'') and  both_site == (0,''):
        site = (0,'양안')
    # 양안, 좌안, 우안 각 결과가 있으면 그냥 그대로 사용해 최대값 가져오기
    else:
        site = max(right_site, left_site, both_site)
    return site[1]

# 각 결과별 데이터 조회
# 정상
def OPH_result_class_001(input_txt): 
    rslt_grp = '정상'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*정상[가-힣]*\s*")
    result_02 = re.compile(r"\s*normal*\s*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    elif re.search(result_02,input_txt.lower()) != None: 
        for m in re.finditer(result_02,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":#\
    #    or\ # 한쪽만 정상인경우 입력하는 case도 있고 안 하는 case도 있음.
    #    OPH_result_class_002(input_txt) !="" or\
    #    OPH_result_class_003(input_txt) !="" or\
    #    OPH_result_class_004(input_txt) !="" or\
    #    OPH_result_class_005(input_txt) !="" or\
    #    OPH_result_class_006_1(input_txt) !="" or\
    #    OPH_result_class_006_2(input_txt) !="" or\
    #    OPH_result_class_007(input_txt) !="" or\
    #    OPH_result_class_008(input_txt) !="" or\
    #    OPH_result_class_009(input_txt) !="" or\
    #    OPH_result_class_010(input_txt) !="":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'E001'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L001'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R001'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd

# 시력정밀
def OPH_result_class_002(input_txt):
    rslt_grp = '시력정밀'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*시력[가-힣]*.*정밀[가-힣]*.*안경[가-힣]*.*교정[가-힣]*.*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O104'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L104'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R104'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    
# 황반변성
def OPH_result_class_003(input_txt): 
    rslt_grp = '황반변성'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result = re.compile(r"\s*황반[가-힣]*\s*변성[가-힣]*\s*")
    if re.search(result,input_txt.lower()) != None: 
        for m in re.finditer(result,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O034'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L025'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R025'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    
# 당뇨병성 망막증
def OPH_result_class_004(input_txt):
    rslt_grp = '당뇨병성 망막증'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*당뇨병성[가-힣]*.*망막증[가-힣]*.*")
    result_02 = re.compile(r"\s*당뇨병성[가-힣]*.*망막병증[가-힣]*.*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    elif re.search(result_02,input_txt.lower()) != None: 
        for m in re.finditer(result_02,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O020'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L020'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R020'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    
# 망막전막
def OPH_result_class_005(input_txt):
    rslt_grp = '망막전막'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*망막[가-힣]*.*전막[가-힣]*.*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O016'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L016'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R016'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd

# 안저정밀 기타
def OPH_result_class_006_1(input_txt):
    rslt_grp = '안저 정밀(기타)'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*안저[가-힣]*.*정밀[가-힣]*.*기타[가-힣]*.*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O301'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L301'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R301'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd

# 드루젠
def OPH_result_class_006_2(input_txt):
    rslt_grp = '드루젠'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*드루젠[가-힣]*\s*")
    result_02 = re.compile(r"\s*drusen*\s*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    elif re.search(result_02,input_txt.lower()) != None: 
        for m in re.finditer(result_02,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O701'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L701'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R701'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd

# 안압 정밀
def OPH_result_class_007(input_txt):
    rslt_grp = '안압 정밀'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*안압[가-힣]*.*정밀[가-힣]*.*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O201'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L201'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R201'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    
# 매체혼탁
def OPH_result_class_008(input_txt):
    rslt_grp = '매체혼탁'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*매체[가-힣]*\s*혼탁[가-힣]*\s*")
    result_02 = re.compile(r"\s*media*\s*opacity*\s*")
    result_03 = re.compile(r"\s*매질[가-힣]*\s*혼탁[가-힣]*\s*")
    result_04 = re.compile(r"\s*백내장[가-힣]*\s*의[가-힣]*\s*")
    re.search(result_01,input_txt.lower())
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            loc = m.start()
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    elif re.search(result_02,input_txt.lower()) != None: 
        for m in re.finditer(result_02,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    elif re.search(result_03,input_txt.lower()) != None: 
        for m in re.finditer(result_03,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
        
    else:
        pre_text = ""
    # 백내장 의심만 있는 경우도 매체혼탁이기는 하지만 결과코드는 별도로 부여함.
    if pre_text == "" and re.search(result_04,input_txt.lower()) != None:
        for m in re.finditer(result_04,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
            # 백내장 의심만 있는 경우는 별도의 결과코드를 제공해 주어야 함.
            if find_site(pre_text) == '양안':
                rslt_cd = 'O014'
                return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
            if find_site(pre_text) == '좌안':
                rslt_cd = 'L014'
                return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
            if find_site(pre_text) == '우안':
                rslt_cd = 'R014'
                return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    elif pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O023'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L023'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R023'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    
# 녹내장 정밀
def OPH_result_class_009(input_txt):
    rslt_grp = '녹내장 정밀'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*녹내장[가-힣]*.*정밀[가-힣]*.*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O061'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L601'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R601'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd

# 시신경 정밀    
def OPH_result_class_010(input_txt):
    rslt_grp = '시신경 정밀'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*시신경[가-힣]*.*정밀[가-힣]*.*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O032'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L027'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R105'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd

#%%
# raw_text = "▣ 결론 및 진단\n\n좌안: 정상\n\n양안: 매체혼탁\n\n우안 : 안저 정밀(황반변성)\n\n▣ 의견\n\n안저 사진상 이상 소견 보이나 시력 정상이므로 경과관찰 요함"
# raw_text = "▣ 결론 및 진단\n\n양안 : 안저 정밀(황반변성)\n\n- B)few drusen (R>L)"
# raw_text = "▣ 결론 및 진단\n\n : 안저 정밀(황반변성)\n\n- B)few drusen (R>L)"
# raw_text = "▣ 결론 및 진단\n\n양안 : 안저 정밀(황반변성)\n\n드루젠\n\n좌안 : 시력 정밀(안경교정 안되면)"
# raw_text = "▣ 결론 및 진단\n양안 : 안저 정밀(황반변성)\n▣ 의견\n안저 사진상 이상 소견 보이나 시력 정상이므로 경과관찰 요함"
# raw_text = "▣ 결론 및 진단\n우안 : 정상\n좌안 : 안저 정밀(기타)\n좌안 망막출혈 의심\n▣ 의견\n안저 사진상 이상 소견 보이나 시력 정상이므로 경과관찰 요함"
# raw_text = " 매체혼탁(Media opacity)  "
# raw_text = "▣ 결론 및 진단\n우안 : 매질혼탁, 시력정밀검사요함\n좌안 : 진료원하시면 각막외래연결=>fellow 선생님 외래로 일단 먼저연결"
# raw_text = " 백내장 의심(초기 백내장)"
# raw_text = "▣ 결론 및 진단\n\n양안 : 정상\n\n▣ 의견\n\n황반변성보다는, 양안 모두 동맥의 경화성 변화 보여 혈압, 고지혈증 등 관리 요합니다. "
# raw_text = '▣ 결론 및 진단\n\n좌안 : 시력 정밀(안경교정 안되면)\n\n양안 : 안압 정밀\n\n좌안 : 안저 정밀(황반변성)'
# raw_text = "▣ 결론 및 진단\n\n우안 : 안저 정밀(황반변성)\n\n양안 : 안저 정밀(당뇨병성 망막증) 의증"
# raw_text = "▣ 결론 및 진단\n\n좌안 : 시력 정밀(안경교정 안되면)\n\n좌안 : 안저 정밀(망막전막)"
# raw_text = "▣ 결론 및 진단\n\n양안 : 안압 정밀\n\n우안 : 시력 정밀(안경교정 안되면)"
# raw_text = "▣ 결론 및 진단\n\n좌안 : 시력 정밀(안경교정 안되면)\n\n좌안 : 녹내장 정밀\n\n좌안 : 안저 정밀(기타)\n\n황반 원공"
# raw_text = "▣ 결론 및 진단\n\n우안 : 시력 정밀(안경교정 안되면)\n\n우안 : 시신경 정밀"
raw_text = "▣ 결론 및 진단\n\n좌안 : 시력 정밀(안경교정 안되면)\n\n양안 : 안저 정밀(기타)\n\n▣ 의견\n\n양안 망막출혈소견"
# print(sample_text)

# result_text = raw_text[except_information(raw_text):except_comments(raw_text)]

print(raw_text)

#%%
def OPH_result_class_tt(input_txt):
    rslt_grp = '안저 정밀(기타)'
    input_txt = input_txt[except_information(input_txt):except_comments(input_txt)]
    result_01 = re.compile(r"\s*안저[가-힣]*.*정밀[가-힣]*.*(기타[가-힣])*.*")
    if re.search(result_01,input_txt.lower()) != None: 
        for m in re.finditer(result_01,input_txt.lower()):
            # 과거 text에는 '결론 및 진단', '검사정보 및 소견'에 대한 문구가 없이 
            # 양안 결과가 바로 결과 text가 보여지기도 함. ex) 매체혼탁(Media opacity)
            loc = m.start()
            if loc == 0:
                pre_text = input_txt
            else:                
                pre_text = input_txt[:loc]
    else:
        pre_text = ""
    if pre_text == "":
        return "" # "","",""
    if find_site(pre_text) == '양안':
        rslt_cd = 'O301'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '좌안':
        rslt_cd = 'L301'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd
    if find_site(pre_text) == '우안':
        rslt_cd = 'R301'
        return rslt_cd # rslt_grp, find_site(pre_text), rslt_cd

OPH_result_class_tt(raw_text)

# %%
gathered_results = (OPH_result_class_001(raw_text),
                    OPH_result_class_002(raw_text),
                    OPH_result_class_003(raw_text),
                    OPH_result_class_004(raw_text),
                    OPH_result_class_005(raw_text),
                    OPH_result_class_006_1(raw_text),
                    OPH_result_class_006_2(raw_text),
                    OPH_result_class_007(raw_text),
                    OPH_result_class_008(raw_text),
                    OPH_result_class_009(raw_text),
                    OPH_result_class_010(raw_text),
                   )

gathered_results = list(filter(None, gathered_results))
gathered_results

# %%
df = pd.read_stata('H:/업무/자료요청/2022년/DATA클리닝/강미라_220525_안저TEXT결과/DATA_TEXT_RSLTCD_0818.dta')

# df['YYYY'] = df['ORDR_YMD'].str.slice(0,4)
df = df.drop(df.loc[df['ORDR_YMD'] < "2018-01-01"].index)

# df
# %%
if __name__ == '__main__': 
    tqdm.pandas()
    df['PREDICT_RSLTCD_01'] = df['EXRS_CTN'].progress_apply(OPH_result_class_001)
    df['PREDICT_RSLTCD_02'] = df['EXRS_CTN'].progress_apply(OPH_result_class_002)
    df['PREDICT_RSLTCD_03'] = df['EXRS_CTN'].progress_apply(OPH_result_class_003)
    df['PREDICT_RSLTCD_04'] = df['EXRS_CTN'].progress_apply(OPH_result_class_004)
    df['PREDICT_RSLTCD_05'] = df['EXRS_CTN'].progress_apply(OPH_result_class_005)
    df['PREDICT_RSLTCD_06'] = df['EXRS_CTN'].progress_apply(OPH_result_class_006_1)
    df['PREDICT_RSLTCD_07'] = df['EXRS_CTN'].progress_apply(OPH_result_class_006_2)
    df['PREDICT_RSLTCD_08'] = df['EXRS_CTN'].progress_apply(OPH_result_class_007)
    df['PREDICT_RSLTCD_09'] = df['EXRS_CTN'].progress_apply(OPH_result_class_008)
    df['PREDICT_RSLTCD_10'] = df['EXRS_CTN'].progress_apply(OPH_result_class_009)
    df['PREDICT_RSLTCD_11'] = df['EXRS_CTN'].progress_apply(OPH_result_class_010)
    
# df

# %%
rslt = '정상'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='E001') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L001') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R001') 
           ).any(axis=1).astype(int)

rslt = '시력정밀'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O104') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L104') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R104') 
           ).any(axis=1).astype(int)

rslt = '황반변성'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O034') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L025') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R025') 
           ).any(axis=1).astype(int)

rslt = '당뇨병성 망막증'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O020') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L020') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R020') 
           ).any(axis=1).astype(int)

rslt = '망막전막'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O016') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L016') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R016') 
           ).any(axis=1).astype(int)

rslt = '안저 정밀(기타)'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O301') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L301') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R301') 
           ).any(axis=1).astype(int)

rslt = '드루젠'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O701') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L701') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R701') 
           ).any(axis=1).astype(int)

rslt = '안압정밀'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O201') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L201') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R201') 
           ).any(axis=1).astype(int)

rslt = '매체혼탁'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O023') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L023') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R023') 
           ).any(axis=1).astype(int)

rslt = '녹내장 정밀'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O061') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L601') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R601') 
           ).any(axis=1).astype(int)

rslt = '시신경 정밀'

df[rslt] = ((df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='O032') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='L027') |
            (df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6']=='R105') 
           ).any(axis=1).astype(int)
df

#%%
df['PREDICT_RSLTCD_01'] = np.where(df['PREDICT_RSLTCD_01'] == "","X",df['PREDICT_RSLTCD_01'])
df['PREDICT_RSLTCD_02'] = np.where(df['PREDICT_RSLTCD_02'] == "","X",df['PREDICT_RSLTCD_02'])
df['PREDICT_RSLTCD_03'] = np.where(df['PREDICT_RSLTCD_03'] == "","X",df['PREDICT_RSLTCD_03'])
df['PREDICT_RSLTCD_04'] = np.where(df['PREDICT_RSLTCD_04'] == "","X",df['PREDICT_RSLTCD_04'])
df['PREDICT_RSLTCD_05'] = np.where(df['PREDICT_RSLTCD_05'] == "","X",df['PREDICT_RSLTCD_05'])
df['PREDICT_RSLTCD_06'] = np.where(df['PREDICT_RSLTCD_06'] == "","X",df['PREDICT_RSLTCD_06'])
df['PREDICT_RSLTCD_07'] = np.where(df['PREDICT_RSLTCD_07'] == "","X",df['PREDICT_RSLTCD_07'])
df['PREDICT_RSLTCD_08'] = np.where(df['PREDICT_RSLTCD_08'] == "","X",df['PREDICT_RSLTCD_08'])
df['PREDICT_RSLTCD_09'] = np.where(df['PREDICT_RSLTCD_09'] == "","X",df['PREDICT_RSLTCD_09'])
df['PREDICT_RSLTCD_10'] = np.where(df['PREDICT_RSLTCD_10'] == "","X",df['PREDICT_RSLTCD_10'])
df['PREDICT_RSLTCD_11'] = np.where(df['PREDICT_RSLTCD_11'] == "","X",df['PREDICT_RSLTCD_11'])
# df
#%%
# 예측 결과코드와 기존 결과코드 비교
# df['RSLTCD_CHK_01'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(set(df.loc[:,'PREDICT_RSLTCD_01'])).any(axis=1).astype(int)
# 위에 방식으로 하게 된다면 값이 null인 것도 1로 표시가 됨 set()이 문제가 있는듯.....
df['RSLTCD_CHK_01'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_01']).any(axis=1).astype(int)
df['RSLTCD_CHK_02'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_02']).any(axis=1).astype(int)
df['RSLTCD_CHK_03'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_03']).any(axis=1).astype(int)
df['RSLTCD_CHK_04'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_04']).any(axis=1).astype(int)
df['RSLTCD_CHK_05'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_05']).any(axis=1).astype(int)
df['RSLTCD_CHK_06'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_06']).any(axis=1).astype(int)
df['RSLTCD_CHK_07'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_07']).any(axis=1).astype(int)
df['RSLTCD_CHK_08'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_08']).any(axis=1).astype(int)
df['RSLTCD_CHK_09'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_09']).any(axis=1).astype(int)
df['RSLTCD_CHK_10'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_10']).any(axis=1).astype(int)
df['RSLTCD_CHK_11'] = df.loc[:,'HLSC_RSLT_CD_1':'HLSC_RSLT_CD_6'].isin(df.loc[:,'PREDICT_RSLTCD_11']).any(axis=1).astype(int)
# df

#%%
# 기존에 변경했던 컬럼 값 null로 변경
df['PREDICT_RSLTCD_01'] = np.where(df['PREDICT_RSLTCD_01'] == "X","",df['PREDICT_RSLTCD_01'])
df['PREDICT_RSLTCD_02'] = np.where(df['PREDICT_RSLTCD_02'] == "X","",df['PREDICT_RSLTCD_02'])
df['PREDICT_RSLTCD_03'] = np.where(df['PREDICT_RSLTCD_03'] == "X","",df['PREDICT_RSLTCD_03'])
df['PREDICT_RSLTCD_04'] = np.where(df['PREDICT_RSLTCD_04'] == "X","",df['PREDICT_RSLTCD_04'])
df['PREDICT_RSLTCD_05'] = np.where(df['PREDICT_RSLTCD_05'] == "X","",df['PREDICT_RSLTCD_05'])
df['PREDICT_RSLTCD_06'] = np.where(df['PREDICT_RSLTCD_06'] == "X","",df['PREDICT_RSLTCD_06'])
df['PREDICT_RSLTCD_07'] = np.where(df['PREDICT_RSLTCD_07'] == "X","",df['PREDICT_RSLTCD_07'])
df['PREDICT_RSLTCD_08'] = np.where(df['PREDICT_RSLTCD_08'] == "X","",df['PREDICT_RSLTCD_08'])
df['PREDICT_RSLTCD_09'] = np.where(df['PREDICT_RSLTCD_09'] == "X","",df['PREDICT_RSLTCD_09'])
df['PREDICT_RSLTCD_10'] = np.where(df['PREDICT_RSLTCD_10'] == "X","",df['PREDICT_RSLTCD_10'])
df['PREDICT_RSLTCD_11'] = np.where(df['PREDICT_RSLTCD_11'] == "X","",df['PREDICT_RSLTCD_11'])
# df

# %%
df.to_excel("H:/업무/자료요청/2022년/DATA클리닝/강미라_220525_안저TEXT결과/DATA_TEXT_RSLTCD_2018_정상좌우안.xlsx",index=False)

# %%
