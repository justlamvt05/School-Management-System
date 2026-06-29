package com.lamthoncoding.myfschoolse1913be.service.impl;

import com.lamthoncoding.myfschoolse1913be.entity.Club;
import com.lamthoncoding.myfschoolse1913be.entity.Student;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.mapper.ClubMapper;
import com.lamthoncoding.myfschoolse1913be.payload.response.ClubResponse;
import com.lamthoncoding.myfschoolse1913be.repository.ClubRepository;
import com.lamthoncoding.myfschoolse1913be.repository.StudentRepository;
import com.lamthoncoding.myfschoolse1913be.service.ClubService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ClubServiceImpl implements ClubService {

    private final ClubRepository clubRepository;
    private final StudentRepository studentRepository;
    private final ClubMapper clubMapper;

    @Override
    public List<ClubResponse> getAllClubs(String phone) {
        log.info("Get all clubs for user: {}", phone);
        List<Club> clubs = clubRepository.findAll();
        Optional<Student> studentOpt = phone != null ? studentRepository.findByUserPhone(phone) : Optional.empty();

        return clubs.stream()
                .map(club -> clubMapper.toResponse(club, studentOpt))
                .collect(Collectors.toList());
    }

    @Override
    public ClubResponse getClubById(Long id, String phone) {
        log.info("Get club {} for user: {}", id, phone);
        Club club = clubRepository.findById(id)
                .orElseThrow(() -> new EntityNotFound("Club not found"));
        Optional<Student> studentOpt = phone != null ? studentRepository.findByUserPhone(phone) : Optional.empty();
        
        return clubMapper.toResponse(club, studentOpt);
    }
}
