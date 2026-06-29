package com.lamthoncoding.myfschoolse1913be.mapper;

import com.lamthoncoding.myfschoolse1913be.dto.UserDto;
import com.lamthoncoding.myfschoolse1913be.entity.Role;
import com.lamthoncoding.myfschoolse1913be.entity.User;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserMapper {
    UserDto toDto(User user);

    default String roleToString(Role role) {
        return role != null && role.getName() != null ? role.getName().name() : null;
    }
}