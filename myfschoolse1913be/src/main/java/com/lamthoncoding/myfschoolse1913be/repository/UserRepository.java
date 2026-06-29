package com.lamthoncoding.myfschoolse1913be.repository;


import com.lamthoncoding.myfschoolse1913be.contraints.UserStatus;
import com.lamthoncoding.myfschoolse1913be.entity.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    @Query("""
    SELECT u FROM User u
    WHERE u.status = :status AND u.phone = :phone
    """)
    Optional<User> findByPhoneAndStatus(String phone, UserStatus status);

    @Query("""
    SELECT u FROM User u
    WHERE u.email = :email AND u.phone = :phone
    """)
    Optional<User> findByEmailAndPhone(
            String email,
            String phone
    );

    Optional<User> findByEmail(String email);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    boolean existsByPhone(String phone);

    Optional<User> findByPhone(String phone);

    @Modifying
    @Query("""
    DELETE FROM User u
    WHERE u.status = 'INACTIVE'
    """)
    void deleteInactiveUsers();
}




